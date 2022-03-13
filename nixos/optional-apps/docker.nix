{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };

  vmPackage = (import "${pkgs.flake.nixpkgs}/nixos/default.nix" {
    configuration = {
      imports = [
        ../common-components/qemu-user-static.nix
        ../common-components/ssh-harden.nix
        ../common-components/users.nix
      ];

      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.hostName = "docker";
      networking.firewall.enable = false;

      nixpkgs.overlays = config.nixpkgs.overlays;

      virtualisation = {
        vmVariant.virtualisation = {
          cores = 8;
          diskSize = 100 * 1024;
          graphics = false;
          memorySize = 8192;
          sharedDirectories."acme.sh" = { source = "/var/lib/acme.sh"; target = "/var/lib/acme.sh"; };
          sharedDirectories.cache = { source = "/var/cache/ci"; target = "/cache"; };
          sharedDirectories.sync = { source = "/nix/persistent/sync-servers"; target = "/sync"; };
        };

        docker = {
          enable = true;
          enableOnBoot = true;
          autoPrune = {
            enable = true;
            flags = [ "-a" ];
          };
          listenOptions = [
            "0.0.0.0:${LT.portStr.Docker}"
            "/run/docker.sock"
          ];

          daemon.settings = {
            userland-proxy = false;
            experimental = true;
            default-runtime = "crun";
            runtimes.crun.path = "${pkgs.crun}/bin/crun";
          };
        };
      };
    };
  }).vm;
in
{
  systemd.services.docker-vm = {
    description = "Docker VM";
    wantedBy = [ "multi-user.target" ];
    environment = {
      NIX_DISK_IMAGE = "/var/lib/vm/docker.qcow2";
      QEMU_NET_OPTS = "hostfwd=tcp:127.0.0.1:${LT.portStr.Docker}-:${LT.portStr.Docker},hostfwd=tcp:127.0.0.1:2223-:2222";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${vmPackage}/bin/run-docker-vm -cpu host";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/vm 755 root root"
  ];

  environment.systemPackages = [
    (pkgs.stdenv.mkDerivation {
      name = "docker-vm";
      version = "0.0.1";

      phases = [ "installPhase" ];
      buildInputs = [ pkgs.makeWrapper ];
      installPhase = ''
        makeWrapper "${pkgs.docker}/bin/docker" "$out/bin/docker-vm" --set DOCKER_HOST "tcp://127.0.0.1:${LT.portStr.Docker}"
      '';
    })
  ];
}
