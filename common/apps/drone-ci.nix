{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  imports = [
    ./docker.nix
    ./vault.nix
  ];

  virtualisation.oci-containers.containers = {
    drone = {
      image = "drone/drone:2";
      environment = {
        DRONE_GITEA_SERVER = "https://git.lantian.pub";
        DRONE_GITEA_CLIENT_ID = "***REMOVED***";
        DRONE_GITEA_CLIENT_SECRET = "***REMOVED***";
        DRONE_RPC_SECRET = "***REMOVED***";
        DRONE_SERVER_HOST = "ci.lantian.pub";
        DRONE_SERVER_PROTO = "https";
        DRONE_USER_CREATE = "username:lantian,admin:true";
        DRONE_JSONNET_ENABLED = "true";
        DRONE_STARLARK_ENABLED = "true";
      };
      ports = [
        "${thisHost.ltnet.IPv4Prefix}.1:13080:80"
      ];
      volumes = [
        "/srv/data/drone:/data"
      ];
    };
    drone-runner = {
      image = "drone/drone-runner-docker:1";
      environment = {
        DRONE_RPC_PROTO = "http";
        DRONE_RPC_HOST = "${thisHost.ltnet.IPv4Prefix}.1:13080";
        DRONE_RPC_SECRET = "***REMOVED***";
        DRONE_RUNNER_CAPACITY = "4";
        DRONE_RUNNER_NAME = "drone-docker";
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://${thisHost.ltnet.IPv4Prefix}.1:13082";
        DRONE_SECRET_PLUGIN_TOKEN = "***REMOVED***";
      };
      volumes = [
        "/run/docker-dind:/run"
        "/cache:/cache"
      ];
      dependsOn = [
        "drone"
        "drone-vault"
      ];
    };
    drone-github = {
      image = "drone/drone:2";
      environment = {
        DRONE_GITHUB_CLIENT_ID = "***REMOVED***";
        DRONE_GITHUB_CLIENT_SECRET = "***REMOVED***";
        DRONE_RPC_SECRET = "***REMOVED***";
        DRONE_SERVER_HOST = "ci-github.lantian.pub";
        DRONE_SERVER_PROTO = "https";
        DRONE_USER_CREATE = "username:xddxdd,admin:true";
        DRONE_REGISTRATION_CLOSED = "true";
        DRONE_JSONNET_ENABLED = "true";
        DRONE_STARLARK_ENABLED = "true";
      };
      ports = [
        "${thisHost.ltnet.IPv4Prefix}.1:13081:80"
      ];
      volumes = [
        "/srv/data/drone-github:/data"
      ];
    };
    drone-runner-github = {
      image = "drone/drone-runner-docker:1";
    environment = {
      DRONE_RPC_PROTO = "http";
      DRONE_RPC_HOST = "${thisHost.ltnet.IPv4Prefix}.1:13081";
      DRONE_RPC_SECRET = "***REMOVED***";
      DRONE_RUNNER_CAPACITY = "4";
      DRONE_RUNNER_NAME = "drone-docker";
      DRONE_SECRET_PLUGIN_ENDPOINT = "http://${thisHost.ltnet.IPv4Prefix}.1:13082";
      DRONE_SECRET_PLUGIN_TOKEN = "***REMOVED***";
    };
      volumes = [
        "/run/docker-dind:/run"
        "/cache:/cache"
      ];
      dependsOn = [
        "drone-github"
        "drone-vault"
      ];
    };
    drone-vault = {
      image = "drone/vault";
      environment = {
        DRONE_DEBUG = "true";
        DRONE_SECRET = "***REMOVED***";
        VAULT_ADDR = "https://vault.lantian.pub";
        VAULT_TOKEN = "***REMOVED***";
      };
      ports = [
        "${thisHost.ltnet.IPv4Prefix}.1:13082:3000"
      ];
    };
    dind = {
      image = "docker:dind";
      volumes = [
        "/cache:/cache"
        "/var/lib/docker-dind:/var/lib/docker"
        "/run/docker-dind:/run"
      ];
      extraOptions = [ "--privileged" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /cache 755 root root"
    "d /var/lib/docker-dind 755 root root"
    "d /run/docker-dind 755 root root"
  ];
}
