{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };

  droneNetns = LT.netns {
    name = "drone";
    birdBindTo = [ "drone.service" ];
  };
  droneGitHubNetns = LT.netns {
    name = "drone-github";
    birdBindTo = [ "drone-github.service" ];
  };
in
{
  imports = [
    ./docker.nix
    ./vault.nix
  ];

  age.secrets.drone-ci-env.file = pkgs.secrets + "/drone-ci-env.age";
  age.secrets.drone-ci-github-env.file = pkgs.secrets + "/drone-ci-github-env.age";
  age.secrets.drone-ci-vault-env.file = pkgs.secrets + "/drone-ci-vault-env.age";

  systemd.services = droneNetns.setup // droneGitHubNetns.setup // {
    drone = droneNetns.bind {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DRONE_DATABASE_DRIVER = "sqlite3";
        DRONE_DATABASE_DATASOURCE = "/var/lib/drone/database.sqlite";
        DRONE_GIT_ALWAYS_AUTH = "true";
        DRONE_GITEA_SERVER = "https://git.lantian.pub";
        DRONE_JSONNET_ENABLED = "true";
        DRONE_SERVER_HOST = "ci.lantian.pub";
        DRONE_SERVER_PORT = ":80";
        DRONE_SERVER_PROTO = "https";
        DRONE_STARLARK_ENABLED = "true";
        DRONE_USER_CREATE = "username:lantian,admin:true";
      };
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-env.path;
        ExecStart = "${pkgs.drone}/bin/drone-server";
        StateDirectory = "drone";
        User = "container";
        Group = "container";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      };
    };
    drone-github = droneGitHubNetns.bind {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DRONE_DATABASE_DRIVER = "sqlite3";
        DRONE_DATABASE_DATASOURCE = "/var/lib/drone-github/database.sqlite";
        DRONE_JSONNET_ENABLED = "true";
        DRONE_REGISTRATION_CLOSED = "true";
        DRONE_SERVER_HOST = "ci-github.lantian.pub";
        DRONE_SERVER_PORT = ":80";
        DRONE_SERVER_PROTO = "https";
        DRONE_STARLARK_ENABLED = "true";
        DRONE_USER_CREATE = "username:xddxdd,admin:true";
      };
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-github-env.path;
        ExecStart = "${pkgs.drone}/bin/drone-server";
        StateDirectory = "drone-github";
        User = "container";
        Group = "container";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      };
    };
    drone-runner = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DOCKER_HOST = "tcp://127.0.0.1:${LT.portStr.Docker}";
        # Make socket bind fail, this won't affect runner functionality
        DRONE_HTTP_BIND = "255.255.255.255:65535";
        DRONE_RPC_HOST = droneNetns.ipv4;
        DRONE_RPC_PROTO = "http";
        DRONE_RUNNER_CAPACITY = "4";
        DRONE_RUNNER_NAME = "drone-docker";
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://127.0.0.1:${LT.portStr.DroneVault}";
      };
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-env.path;
        ExecStart = "${pkgs.drone-runner-docker}/bin/drone-runner-docker";
      };
    };
    drone-runner-github = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DOCKER_HOST = "tcp://127.0.0.1:${LT.portStr.Docker}";
        # Make socket bind fail, this won't affect runner functionality
        DRONE_HTTP_BIND = "255.255.255.255:65535";
        DRONE_RPC_HOST = droneGitHubNetns.ipv4;
        DRONE_RPC_PROTO = "http";
        DRONE_RUNNER_CAPACITY = "4";
        DRONE_RUNNER_NAME = "drone-docker";
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://127.0.0.1:${LT.portStr.DroneVault}";
      };
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-github-env.path;
        ExecStart = "${pkgs.drone-runner-docker}/bin/drone-runner-docker";
        DynamicUser = true;
      };
    };
    drone-vault = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DRONE_BIND = "127.0.0.1:${LT.portStr.DroneVault}";
        DRONE_DEBUG = "true";
        VAULT_ADDR = "http://127.0.0.1:${LT.portStr.Vault}";
      };
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-vault-env.path;
        ExecStart = "${pkgs.drone-vault}/bin/drone-vault";
        DynamicUser = true;
      };
    };
  };

  services.nginx.virtualHosts = {
    "ci.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { noindex = true; } {
        "/" = {
          proxyPass = "http://${droneNetns.ipv4}";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
    "ci-github.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { noindex = true; } {
        "/" = {
          proxyPass = "http://${droneGitHubNetns.ipv4}";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
  };
}
