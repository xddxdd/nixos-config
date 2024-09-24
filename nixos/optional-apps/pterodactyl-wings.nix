{ pkgs, ... }:
{
  imports = [ ./docker.nix ];

  containers.docker.bindMounts = {
    pterodactyl-lib = {
      hostPath = "/var/lib/pterodactyl";
      mountPoint = "/var/lib/pterodactyl";
      isReadOnly = false;
    };
    pterodactyl-tmp = {
      hostPath = "/tmp/pterodactyl";
      mountPoint = "/tmp/pterodactyl";
      isReadOnly = false;
    };
  };

  environment.persistence."/nix/persistent" = {
    directories = [ "/etc/pterodactyl" ];
  };

  environment.systemPackages = [ pkgs.nur-xddxdd.pterodactyl-wings ];

  systemd.services.pterodactyl-wings = {
    description = "Pterodactyl Wings Daemon";
    after = [
      "network.target"
      "container@docker.service"
    ];
    requires = [
      "network.target"
      "container@docker.service"
    ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      DOCKER_HOST = "unix:///run/docker-vm/docker.sock";
    };
    serviceConfig = {
      ExecStart = "${pkgs.nur-xddxdd.pterodactyl-wings}/bin/wings";

      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallErrorNumber = "EPERM";
    };
  };

  systemd.tmpfiles.rules = [ "d /tmp/pterodactyl 755 root root" ];
}
