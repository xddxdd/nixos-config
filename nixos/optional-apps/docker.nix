{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "docker-vm" ''
      export DOCKER_HOST=unix:///run/docker-vm/docker.sock
      exec ${pkgs.docker}/bin/docker "$@"
    '')
  ];

  systemd.services."container@docker".environment = {
    SYSTEMD_NSPAWN_UNIFIED_HIERARCHY = "1";
  };

  systemd.tmpfiles.rules = [
    "d /var/cache/ci 755 root root"
    "d /nix/persistent/sync-servers 755 root root"
    "d /var/lib/docker 755 root root"
    "d /run/docker-vm 755 root root"
  ];

  containers.docker = LT.container {
    name = "docker";

    outerConfig = {
      extraFlags = [
        "--system-call-filter=add_key"
        "--system-call-filter=keyctl"
        "--system-call-filter=bpf"
      ];

      bindMounts = {
        cache = {
          hostPath = "/var/cache/ci";
          mountPoint = "/cache";
          isReadOnly = false;
        };
        sync = {
          hostPath = "/nix/persistent/sync-servers";
          mountPoint = "/sync";
          isReadOnly = false;
        };
        docker = {
          hostPath = "/var/lib/docker";
          mountPoint = "/var/lib/docker";
          isReadOnly = false;
        };
        socket = {
          hostPath = "/run/docker-vm";
          mountPoint = "/run/docker-vm";
          isReadOnly = false;
        };
      };
    };

    innerConfig = _: {
      networking = {
        firewall.enable = false;
        firewall.checkReversePath = false;
        nat.enable = false;
        useDHCP = false;
      };

      nix.enable = false;
      nixpkgs.overlays = config.nixpkgs.overlays;

      services.journald.extraConfig = config.services.journald.extraConfig;
      services.timesyncd.enable = false;

      systemd.sockets.docker.socketConfig = {
        SocketMode = lib.mkForce "0666";
      };

      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune = {
          enable = true;
          flags = [ "-a" ];
        };
        listenOptions = [
          "/run/docker-vm/docker.sock"
        ];

        daemon.settings = {
          experimental = true;
          userland-proxy = false;
        };
      };
    };
  };
}
