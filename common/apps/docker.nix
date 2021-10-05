{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  virtualisation.podman.enable = pkgs.lib.mkForce false;
  virtualisation.oci-containers.backend = pkgs.lib.mkForce "docker";

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      flags = [ "-a" ];
    };
  };

  environment.etc."docker/daemon.json".text = builtins.toJSON {
    "userland-proxy" = false;
    "experimental" = true;
    "ip6tables" = true;
    "default-runtime" = "crun";
    "runtimes" = {
      "crun" = {
        "path" = "${pkgs.crun}/bin/crun";
      };
    };
    "metrics-addr" = "${thisHost.ltnet.IPv4Prefix}.1:9323";
  };

  systemd.network.netdevs = {
    docker0.netdevConfig = {
      Kind = "bridge";
      Name = "docker0";
    };
    docker0-dummy.netdevConfig = {
      Kind = "dummy";
      Name = "docker0-dummy";
    };
  };

  systemd.network.networks = {
    docker0-dummy = {
      matchConfig = {
        Name = "docker0-dummy";
      };

      bridge = [
        "docker0"
      ];
    };
    docker0 = {
      matchConfig = {
        Name = "docker0";
      };

      networkConfig = {
        IPv6PrivacyExtensions = false;
      };

      addresses = [
        {
          addressConfig = {
            Address = "172.17.0.1/16";
          };
        }
      ];
    };
  };
}
