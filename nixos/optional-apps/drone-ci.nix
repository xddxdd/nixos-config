{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
in
{
  imports = [
    ./docker.nix
    ./vault.nix
  ];

  age.secrets.drone-ci-env.file = pkgs.secrets + "/drone-ci-env.age";
  age.secrets.drone-ci-github-env.file = pkgs.secrets + "/drone-ci-github-env.age";
  age.secrets.drone-ci-vault-env.file = pkgs.secrets + "/drone-ci-vault-env.age";

  systemd.services = {
    drone = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DRONE_DATABASE_DRIVER = "sqlite3";
        DRONE_DATABASE_DATASOURCE = "/var/lib/drone/database.sqlite";
        DRONE_GIT_ALWAYS_AUTH = "true";
        DRONE_GITEA_SERVER = "https://git.lantian.pub";
        DRONE_JSONNET_ENABLED = "true";
        DRONE_SERVER_HOST = "ci.lantian.pub";
        DRONE_SERVER_PORT = ":80";
        DRONE_SERVER_UNIX = "/run/drone/drone.sock";
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
        RuntimeDirectory = "drone";
        User = "container";
        Group = "container";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        UMask = "000";
      };
    };
    drone-github = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DRONE_DATABASE_DRIVER = "sqlite3";
        DRONE_DATABASE_DATASOURCE = "/var/lib/drone-github/database.sqlite";
        DRONE_JSONNET_ENABLED = "true";
        DRONE_REGISTRATION_CLOSED = "true";
        DRONE_SERVER_HOST = "ci-github.lantian.pub";
        DRONE_SERVER_PORT = ":80";
        DRONE_SERVER_UNIX = "/run/drone-github/drone-github.sock";
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
        RuntimeDirectory = "drone-github";
        User = "container";
        Group = "container";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        UMask = "000";
      };
    };

    drone-docker = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DOCKER_HOST = "unix:///run/docker-vm/docker.sock";
        # Make socket bind fail, this won't affect runner functionality
        DRONE_HTTP_BIND = "255.255.255.255:65535";
        DRONE_RPC_HOST = "drone.localhost";
        DRONE_RPC_PROTO = "http";
        DRONE_RUNNER_CAPACITY = "4";
        DRONE_RUNNER_NAME = "drone-docker";
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://drone-vault.localhost";
      };
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-env.path;
        ExecStart = "${pkgs.drone-runner-docker}/bin/drone-runner-docker";
      };
    };
    drone-docker-github = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DOCKER_HOST = "unix:///run/docker-vm/docker.sock";
        # Make socket bind fail, this won't affect runner functionality
        DRONE_HTTP_BIND = "255.255.255.255:65535";
        DRONE_RPC_HOST = "drone-github.localhost";
        DRONE_RPC_PROTO = "http";
        DRONE_RUNNER_CAPACITY = "4";
        DRONE_RUNNER_NAME = "drone-docker";
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://drone-vault.localhost";
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

    drone-exec = {
      path = with pkgs; [ bash coreutils git nix ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        # Make socket bind fail, this won't affect runner functionality
        DRONE_HTTP_BIND = "255.255.255.255:65535";
        DRONE_RPC_HOST = "drone.localhost";
        DRONE_RPC_PROTO = "http";
        DRONE_RUNNER_CAPACITY = "4";
        DRONE_RUNNER_NAME = "drone-exec";
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://drone-vault.localhost";
      };
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-env.path;
        ExecStart = "${pkgs.drone-runner-exec}/bin/drone-runner-exec";
        Nice = "19";
      };
    };
    drone-exec-github = {
      path = with pkgs; [ bash coreutils git nix ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        # Make socket bind fail, this won't affect runner functionality
        DRONE_HTTP_BIND = "255.255.255.255:65535";
        DRONE_RPC_HOST = "drone-github.localhost";
        DRONE_RPC_PROTO = "http";
        DRONE_RUNNER_CAPACITY = "4";
        DRONE_RUNNER_NAME = "drone-exec";
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://drone-vault.localhost";
      };
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-github-env.path;
        ExecStart = "${pkgs.drone-runner-exec}/bin/drone-runner-exec";
        Nice = "19";
      };
    };

    drone-vault = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DRONE_UNIX_SOCKET = "/run/drone-vault/drone-vault.sock";
        VAULT_ADDR = "http://127.0.0.1:${LT.portStr.Vault}";
      };
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-vault-env.path;
        ExecStart = "${pkgs.drone-vault}/bin/drone-vault";
        RuntimeDirectory = "drone-vault";
        User = "container";
        Group = "container";
        UMask = "000";
      };
    };
  };

  services.nginx.virtualHosts = {
    "ci.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { } {
        "/" = {
          proxyPass = "http://unix:/run/drone/drone.sock";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };

    "drone.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf { } {
        "/" = {
          proxyPass = "http://unix:/run/drone/drone.sock";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost;
    };

    "ci-github.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { } {
        "/" = {
          proxyPass = "http://unix:/run/drone-github/drone-github.sock";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };

    "drone-github.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf { } {
        "/" = {
          proxyPass = "http://unix:/run/drone-github/drone-github.sock";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost;
    };

    "drone-vault.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf { } {
        "/" = {
          proxyPass = "http://unix:/run/drone-vault/drone-vault.sock";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost;
    };
  };
}
