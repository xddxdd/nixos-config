{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;

  vmPackage = (import "${pkgs.flakeInputs.nixpkgs}/nixos/default.nix" {
    configuration = {
      imports = [
        ../ssh-harden.nix
        ../users.nix
      ];

      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.hostName = "docker";
      networking.firewall.enable = false;

      virtualisation = {
        cores = 8;
        diskSize = 100 * 1024;
        graphics = false;
        memorySize = 8192;
        sharedDirectories.cache = { source = "/var/cache/ci"; target = "/cache"; };

        docker = {
          enable = true;
          enableOnBoot = true;
          autoPrune = {
            enable = true;
            flags = [ "-a" ];
          };
          listenOptions = [
            "0.0.0.0:2375"
            "/run/docker.sock"
          ];
        };
      };

      environment.etc."docker/daemon.json".text = builtins.toJSON {
        "userland-proxy" = false;
        "experimental" = true;
        "default-runtime" = "crun";
        "runtimes" = {
          "crun" = {
            "path" = "${pkgs.crun}/bin/crun";
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
      QEMU_NET_OPTS = "hostfwd=tcp:127.0.0.1:2375-:2375,hostfwd=tcp:127.0.0.1:2223-:2222";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${vmPackage}/bin/run-docker-vm";
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
        makeWrapper "${pkgs.docker}/bin/docker" "$out/bin/docker-vm" --set DOCKER_HOST "tcp://127.0.0.1:2375"
      '';
    })
  ];
}
