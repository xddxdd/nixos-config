{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
let
  ltnetSSHConfig = ''
    Port 2222
    HostKeyAlgorithms ssh-ed25519
    KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512,sntrup761x25519-sha512@openssh.com
    Ciphers aes256-gcm@openssh.com
    PubkeyAcceptedAlgorithms ssh-ed25519
  '';
in
{
  age.secrets.sftp-privkey.file = inputs.secrets + "/sftp-privkey.age";

  # Keep compatibility with PVE which expect SSH keys in standard location
  preservation.preserveAt."/nix/persistent" = {
    files = builtins.map LT.preservation.mkFile [
      {
        file = "/etc/ssh/ssh_host_ed25519_key.pub";
        mode = "0644";
      }
      {
        file = "/etc/ssh/ssh_host_ed25519_key";
        mode = "0600";
      }
      {
        file = "/etc/ssh/ssh_host_rsa_key.pub";
        mode = "0644";
      }
      {
        file = "/etc/ssh/ssh_host_rsa_key";
        mode = "0600";
      }
    ];
  };

  programs.ssh = {
    package = pkgs.openssh_hpn;

    knownHosts =
      (builtins.listToAttrs (
        lib.flatten (
          lib.mapAttrsToList (
            n: v:
            let
              hostNames = [
                "${n}.lantian.pub"
                "[${n}.lantian.pub]:2222"
                "${n}.xuyh0120.win"
                "[${n}.xuyh0120.win]:2222"
              ];
            in
            (lib.optional ((LT.hosts."${n}".ssh.rsa or "") != "") {
              name = "${n}-rsa";
              value = {
                inherit hostNames;
                publicKey = LT.hosts."${n}".ssh.rsa;
              };
            })
            ++ (lib.optional ((LT.hosts."${n}".ssh.ed25519 or "") != "") {
              name = "${n}-ed25519";
              value = {
                inherit hostNames;
                publicKey = LT.hosts."${n}".ssh.ed25519;
              };
            })
          ) LT.hosts
        )
      ))
      // {
        "your-storagebox.de-rsa" = {
          hostNames = [ "[u378583.your-storagebox.de]:23" ];
          publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
        };
        "your-storagebox.de-ecdsa" = {
          hostNames = [ "[u378583.your-storagebox.de]:23" ];
          publicKey = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGK0po6usux4Qv2d8zKZN1dDvbWjxKkGsx7XwFdSUCnF19Q8psHEUWR7C/LtSQ5crU/g+tQVRBtSgoUcE8T+FWp5wBxKvWG2X9gD+s9/4zRmDeSJR77W6gSA/+hpOZoSE+4KgNdnbYSNtbZH/dN74EG7GLb/gcIpbUUzPNXpfKl7mQitw==";
        };
        "your-storagebox.de-ed25519" = {
          hostNames = [ "[u378583.your-storagebox.de]:23" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
        };
      };
  };

  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    sftpServerExecutable = "internal-sftp";
    authorizedKeysInHomedir = false;
    hostKeys = [
      {
        bits = 4096;
        path = "/nix/persistent/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "/nix/persistent/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings = {
      PermitRootLogin = lib.mkForce "prohibit-password";
      Ciphers = [
        "aes256-gcm@openssh.com"
        "chacha20-poly1305@openssh.com"
        "aes128-gcm@openssh.com"
      ];
      KexAlgorithms = [
        "mlkem768x25519-sha256"
        "sntrup761x25519-sha512"
        "sntrup761x25519-sha512@openssh.com"
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
      ];
      Macs = [
        "hmac-sha2-512"
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256"
        "hmac-sha2-256-etm@openssh.com"
      ];
    };
  };

  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      User root
      Port 22
      PubkeyAcceptedKeyTypes ssh-ed25519

    Host sub1.u378583.your-storagebox.de
      HostName u378583.your-storagebox.de
      User u378583-sub1
      Port 23
      IdentityFile ${config.age.secrets.sftp-privkey.path}

    Host sub2.u378583.your-storagebox.de
      HostName u378583.your-storagebox.de
      User u378583-sub2
      Port 23
      IdentityFile ${config.age.secrets.sftp-privkey.path}

    Host sftp.lt-home-vm.xuyh0120.win
      HostName lt-home-vm.xuyh0120.win
      User sftp
      IdentityFile ${config.age.secrets.sftp-privkey.path}
      ${ltnetSSHConfig}

    Host git.lantian.pub
      User git
      ${ltnetSSHConfig}

    Host *.lantian.pub
      User root
      ${ltnetSSHConfig}

    Host *.xuyh0120.win
      User root
      ${ltnetSSHConfig}

    Host localhost
      ${ltnetSSHConfig}

    Host *
      ForwardAgent no
      Compression no
      ServerAliveInterval 0
      ServerAliveCountMax 3
      HashKnownHosts no
      UserKnownHostsFile /dev/null
      ControlMaster no
      ControlPath none
      ControlPersist no

      HostKeyAlgorithms +ssh-rsa
      KexAlgorithms ^mlkem768x25519-sha256,sntrup761x25519-sha512,sntrup761x25519-sha512@openssh.com
      PubkeyAcceptedAlgorithms +ssh-rsa

      StrictHostKeyChecking no
      # DNS lookup is slow, use predefined knownHosts for my servers
      VerifyHostKeyDNS no
      LogLevel ERROR
  '';

  systemd.services.sshd.environment = {
    # XZ backdoor kill switch
    "yolAbejyiejuvnup" = "Evjtgvsh5okmkAvj";
  };

  # Prevent regular OpenSSH from sneaking in
  system.forbiddenDependenciesRegexes = [ "^openssh-[0-9p\\.]+$" ];
}
