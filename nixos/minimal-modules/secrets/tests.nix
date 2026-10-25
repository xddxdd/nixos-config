let
  flake = builtins.getFlake "path:${toString ../../..}";
  pkgs = flake.inputs.nixpkgs.legacyPackages.x86_64-linux;
in
pkgs.testers.runNixOSTest {
  name = "lantian-secrets-audit";
  nodes.machine =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        ./default.nix
        ../harden.nix
        ../../minimal-components/decoy-secrets.nix
        ../../minimal-components/auditd.nix
        ../../minimal-components/audit-loki.nix
        ../../minimal-components/snakeoil-tls.nix
      ];
      _module.args.LT = {
        hosts.colocrossing.ltnet.IPv4 = "127.0.0.1";
        port.Loki = 3100;
      };
      time.timeZone = "UTC";
      virtualisation.memorySize = 2048;
      users.users.lantian = {
        isNormalUser = true;
        uid = 1000;
        group = "lantian";
      };
      users.groups.lantian = { };
      users.users.audit-service = {
        isSystemUser = true;
        uid = 150;
        group = "audit-service";
      };
      users.groups.audit-service.gid = 150;
      lantian.secrets.example = {
        command = "printf invoked >> /var/lib/generator-count; ${lib.getExe pkgs.pwgen} -s 48 1";
        owner = "audit-service";
        group = "audit-service";
        mode = "0640";
      };
      fileSystems."/nix/persistent/mounted" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "mode=0755" ];
      };
      systemd.services.bind-test-logs = {
        wantedBy = [ "sysinit.target" ];
        after = [ "local-fs.target" ];
        before = [
          "systemd-tmpfiles-setup.service"
          "systemd-journal-flush.service"
          "auditd.service"
        ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          mkdir -p /nix/persistent/log /var/log
          ${pkgs.util-linux}/bin/mount --bind /nix/persistent/log /var/log
        '';
      };
      services.nginx = {
        enable = true;
        virtualHosts.localhost = {
          onlySSL = true;
          listen = [
            {
              addr = "127.0.0.1";
              port = 8443;
              ssl = true;
            }
          ];
          sslCertificate = config.lantian.secrets.tls-snakeoil.path;
          sslCertificateKey = config.lantian.secrets.tls-snakeoil.path;
          locations."/".return = "204";
        };
      };
      systemd.services.nginx = {
        after = [ "lantian-secrets.service" ];
        requires = [ "lantian-secrets.service" ];
      };
      systemd.services.mock-loki = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.python3}/bin/python3 ${./mock-loki.py}";
          RuntimeDirectory = "mock-loki";
        };
      };
      systemd.tmpfiles.rules = [
        "d /home/shared 0755 root root - -"
        "f /home/shared/ordinary 0644 root root - ordinary"
        "f /root/ordinary 0600 root root - ordinary"
        "f /nix/persistent/ordinary 0644 root root - ordinary"
        "f /nix/persistent/mounted/ordinary 0644 root root - ordinary"
      ];
    };
  testScript = ''
    import re
    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("systemctl is-active lantian-secrets.service auditd.service audit-rules-nixos.service")
    machine.wait_for_unit("audit-loki.service")
    machine.wait_for_unit("mock-loki.service")
    forwarder_pid = machine.succeed("systemctl show audit-loki -p MainPID --value").strip()
    forwarder_uid = int(machine.succeed(f"awk '/^Uid:/ {{print $2}}' /proc/{forwarder_pid}/status"))
    assert 61184 <= forwarder_uid <= 65519
    machine.succeed("${pkgs.openssl}/bin/openssl x509 -in /var/lib/lantian-secrets/tls-snakeoil -noout -checkend 86400")
    machine.succeed("${pkgs.openssl}/bin/openssl pkey -in /var/lib/lantian-secrets/tls-snakeoil -check -noout")
    tls_fingerprint = machine.succeed("sha256sum /var/lib/lantian-secrets/tls-snakeoil").split()[0]
    machine.wait_for_unit("nginx.service")
    machine.succeed("curl --fail --cacert /var/lib/lantian-secrets/tls-snakeoil https://localhost:8443/")
    public_cert = machine.succeed("${pkgs.openssl}/bin/openssl x509 -in /var/lib/lantian-secrets/tls-snakeoil -pubkey -noout")
    public_key = machine.succeed("${pkgs.openssl}/bin/openssl pkey -in /var/lib/lantian-secrets/tls-snakeoil -pubout")
    assert public_cert == public_key
    assert not machine.succeed("systemctl --failed --no-legend").strip()
    machine.succeed("test $(stat -c '%a:%U:%G' /var/lib/lantian-secrets/example) = 640:audit-service:audit-service")
    machine.succeed("runuser -u audit-service -- test -r /var/lib/lantian-secrets/example")
    first = machine.succeed("sha256sum /var/lib/lantian-secrets/example").split()[0]
    machine.succeed("chmod 644 /var/lib/lantian-secrets/example; chown root:root /var/lib/lantian-secrets/example; systemctl restart lantian-secrets")
    assert machine.succeed("sha256sum /var/lib/lantian-secrets/example").split()[0] == first
    machine.succeed("test $(cat /var/lib/generator-count) = invoked")
    machine.succeed("systemctl is-active audit-rules-nixos lantian-secrets")
    machine.succeed("test $(stat -c '%a:%U:%G' /var/lib/lantian-secrets/example) = 640:audit-service:audit-service")
    machine.succeed("test ! -e /root/.ssh/id_ed25519; test ! -e /root/.aws/credentials; test ! -e /root/.pgpass; test ! -e /root/.my.cnf; test ! -e /root/.npmrc")
    machine.succeed("${pkgs.openssh}/bin/ssh-keygen -y -f /root/.ssh/id_ed25519.bak >/dev/null")
    machine.succeed("grep -Eq '^aws_access_key_id = AKIA[A-Z0-9]{16}$' /root/.aws/credentials.bak")
    # UID filters use current process identities, not an unset daemon loginuid.
    print(machine.succeed("auditctl -s; auditctl -l; journalctl -u auditd -b -n 15 --no-pager"))
    machine.succeed("runuser -u audit-service -- cat /home/shared/ordinary >/dev/null")
    machine.wait_until_succeeds("ausearch -if /var/log/audit/audit.log -k service-home --raw | grep 'uid=150'", timeout=30)
    machine.succeed("${pkgs.python3}/bin/python3 -c 'import os; os.setresuid(1000,150,1000); open(\"/home/shared/ordinary\").read()'")
    machine.wait_until_succeeds("ausearch -if /var/log/audit/audit.log -k service-home --raw | grep 'uid=1000.*euid=150'", timeout=30)
    machine.succeed("${pkgs.python3}/bin/python3 -c 'import ctypes; ctypes.CDLL(None).setfsuid(150); open(\"/home/shared/ordinary\").read()'")
    machine.wait_until_succeeds("ausearch -if /var/log/audit/audit.log -k service-home --raw | grep 'uid=0.*euid=0.*fsuid=150'", timeout=30)
    machine.succeed("${pkgs.python3}/bin/python3 -c 'import os; os.setresuid(1,1,1); open(\"/home/shared/ordinary\").read()'")
    machine.succeed("${pkgs.python3}/bin/python3 -c 'import os; os.setresuid(999,999,999); open(\"/home/shared/ordinary\").read()'")
    machine.wait_until_succeeds("ausearch -if /var/log/audit/audit.log -k service-home --raw | grep ' uid=1 '", timeout=30)
    machine.wait_until_succeeds("ausearch -if /var/log/audit/audit.log -k service-home --raw | grep ' uid=999 '", timeout=30)
    machine.succeed("cat /root/.ssh/id_ed25519.bak >/dev/null")
    machine.succeed("runuser -u lantian -- cat /home/lantian/.aws/credentials.bak >/dev/null")
    machine.wait_until_succeeds("ausearch -if /var/log/audit/audit.log -k credential-access --raw | grep 'uid=1000'", timeout=30)
    machine.succeed("runuser -u audit-service -- cat /nix/persistent/ordinary >/dev/null")
    machine.succeed("runuser -u audit-service -- cat /nix/persistent/mounted/ordinary >/dev/null")
    machine.succeed("${pkgs.python3}/bin/python3 -c 'import os; os.setresuid(1,1,1); open(\"/nix/persistent/ordinary\").read()'")
    machine.succeed("${pkgs.python3}/bin/python3 -c 'import os; os.setresuid(999,999,999); open(\"/nix/persistent/ordinary\").read()'")
    machine.succeed("${pkgs.python3}/bin/python3 -c 'import os; os.setresuid(1000,150,1000); open(\"/nix/persistent/ordinary\").read()'")
    machine.succeed("${pkgs.python3}/bin/python3 -c 'import ctypes; ctypes.CDLL(None).setfsuid(150); open(\"/nix/persistent/ordinary\").read()'")
    for identity in [" uid=1 ", " uid=150 ", " uid=999 ", "uid=1000.*euid=150", "uid=0.*euid=0.*fsuid=150"]:
        machine.wait_until_succeeds(f"ausearch -if /var/log/audit/audit.log -k persistent-access --raw | grep '{identity}'", timeout=30)
    normal_persistent_pid = machine.succeed("runuser -u lantian -- sh -c 'echo $$; exec cat /nix/persistent/mounted/ordinary >/dev/null'").strip()
    root_persistent_pid = machine.succeed("sh -c 'echo $$; exec cat /nix/persistent/ordinary >/dev/null'").strip()
    machine.succeed("sleep 3")
    for pid in [normal_persistent_pid, root_persistent_pid]:
        machine.fail(f"ausearch -if /var/log/audit/audit.log -k persistent-access -p {pid} --raw")
    # The same watched inode must remain visible through a bind-mount alias.
    machine.succeed("mkdir /var/lib/audit-alias; mount --bind /nix/persistent/mounted /var/lib/audit-alias")
    machine.succeed("runuser -u audit-service -- cat /var/lib/audit-alias/ordinary >/dev/null")
    machine.wait_until_succeeds("ausearch -if /var/log/audit/audit.log -k persistent-access --raw | grep '/var/lib/audit-alias/ordinary'", timeout=30)
    # A denied root-directory traversal must be visible for service UIDs too.
    machine.fail("runuser -u audit-service -- cat /root/ordinary >/dev/null")
    machine.wait_until_succeeds("ausearch -if /var/log/audit/audit.log -k access-denied --raw | grep 'exit=-13'", timeout=30)
    machine.fail("runuser -u lantian -- cat /root/.aws/credentials.bak >/dev/null")
    machine.wait_until_succeeds("ausearch -if /var/log/audit/audit.log -k access-denied --raw | grep '/root/.aws/credentials.bak'", timeout=30)
    # Success by ordinary root/user accounts is not a service-home match.
    normal_pid = machine.succeed("runuser -u lantian -- sh -c 'echo $$; exec cat /home/shared/ordinary >/dev/null'").strip()
    machine.fail(f"ausearch -if /var/log/audit/audit.log -k service-home -p {normal_pid} --raw")
    root_pid = machine.succeed("sh -c 'echo $$; exec cat /root/ordinary >/dev/null'").strip()
    machine.fail(f"ausearch -if /var/log/audit/audit.log -k service-home -p {root_pid} --raw")
    machine.wait_until_succeeds("grep -q persistent-access /run/mock-loki/received.jsonl", timeout=90)
    machine.wait_until_succeeds("grep -q credential-access /run/mock-loki/received.jsonl", timeout=90)
    machine.succeed("systemctl stop mock-loki; install -m 644 /dev/null /nix/persistent/retry-after-outage")
    for i in range(30):
        machine.succeed("runuser -u audit-service -- cat /nix/persistent/retry-after-outage >/dev/null")
    machine.sleep(15)
    machine.succeed("test -s /run/audit-loki/forwarder.log")
    machine.fail(f"ausearch -if /var/log/audit/audit.log -k persistent-access -p {forwarder_pid} --raw")
    machine.fail(f"ausearch -if /var/log/audit/audit.log -k access-denied -p {forwarder_pid} --raw")
    machine.succeed("systemctl restart audit-loki; systemctl start mock-loki")
    machine.wait_until_succeeds("grep -q retry-after-outage /run/mock-loki/received.jsonl", timeout=120)
    machine.succeed("systemctl restart auditd; systemctl is-active auditd audit-rules-nixos")
    machine.succeed("runuser -u audit-service -- cat /home/shared/ordinary >/dev/null")
    machine.wait_until_succeeds("ausearch -if /var/log/audit/audit.log -k service-home --raw | grep 'uid=150'", timeout=30)
    machine.succeed("sleep 3")
    status = machine.succeed("auditctl -s")
    assert re.search(r"(?m)^lost 0$", status), status
    assert not machine.succeed("systemctl --failed --no-legend").strip()
    # Reboot does not rerun the persistent default generator.
    machine.shutdown()
    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("systemctl is-active auditd audit-rules-nixos lantian-secrets")
    machine.wait_for_unit("audit-loki.service")
    machine.wait_for_unit("mock-loki.service")
    machine.succeed("cat /root/.ssh/id_ed25519.bak >/dev/null")
    machine.wait_until_succeeds("grep -q credential-access /run/mock-loki/received.jsonl", timeout=90)
    assert machine.succeed("sha256sum /var/lib/lantian-secrets/example").split()[0] == first
    machine.succeed("test $(cat /var/lib/generator-count) = invoked")
    assert machine.succeed("sha256sum /var/lib/lantian-secrets/tls-snakeoil").split()[0] == tls_fingerprint
  '';
}
