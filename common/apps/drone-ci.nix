{ config, pkgs, ... }:

let
  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };
in
{
  imports = [
    ./docker.nix
    ./vault.nix
  ];

  age.secrets.drone-ci-env.file = ../../secrets/drone-ci-env.age;
  age.secrets.drone-ci-github-env.file = ../../secrets/drone-ci-github-env.age;
  age.secrets.drone-ci-vault-env.file = ../../secrets/drone-ci-vault-env.age;

  virtualisation.oci-containers.containers = {
    drone = {
      image = "drone/drone:2";
      environment = {
        DRONE_GITEA_SERVER = "https://git.lantian.pub";
        DRONE_JSONNET_ENABLED = "true";
        DRONE_SERVER_HOST = "ci.lantian.pub";
        DRONE_SERVER_PROTO = "https";
        DRONE_STARLARK_ENABLED = "true";
        DRONE_USER_CREATE = "username:xddxdd,admin:true";
      };
      environmentFiles = [ config.age.secrets.drone-ci-env.path ];
      ports = [
        "127.0.0.1:13080:80"
      ];
      volumes = [
        "/var/lib/drone:/data"
      ];
    };
    drone-github = {
      image = "drone/drone:2";
      environment = {
        DRONE_JSONNET_ENABLED = "true";
        DRONE_REGISTRATION_CLOSED = "true";
        DRONE_SERVER_HOST = "ci-github.lantian.pub";
        DRONE_SERVER_PROTO = "https";
        DRONE_STARLARK_ENABLED = "true";
        DRONE_USER_CREATE = "username:xddxdd,admin:true";
      };
      environmentFiles = [ config.age.secrets.drone-ci-github-env.path ];
      ports = [
        "127.0.0.1:13081:80"
      ];
      volumes = [
        "/var/lib/drone-github:/data"
      ];
    };
  };

  systemd.services = {
    drone-runner = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DOCKER_HOST = "tcp://127.0.0.1:2375";
        # Make socket bind fail, this won't affect runner functionality
        DRONE_HTTP_BIND = "255.255.255.255:65535";
        DRONE_RPC_HOST = "127.0.0.1:13080";
        DRONE_RPC_PROTO = "http";
        DRONE_RUNNER_CAPACITY = "4";
        DRONE_RUNNER_NAME = "drone-docker";
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://127.0.0.1:13082";
      };
      serviceConfig = {
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
        DOCKER_HOST = "tcp://127.0.0.1:2375";
        # Make socket bind fail, this won't affect runner functionality
        DRONE_HTTP_BIND = "255.255.255.255:65535";
        DRONE_RPC_HOST = "127.0.0.1:13081";
        DRONE_RPC_PROTO = "http";
        DRONE_RUNNER_CAPACITY = "4";
        DRONE_RUNNER_NAME = "drone-docker";
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://127.0.0.1:13082";
      };
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-github-env.path;
        ExecStart = "${pkgs.drone-runner-docker}/bin/drone-runner-docker";
      };
    };
    drone-vault = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DRONE_BIND = "127.0.0.1:13082";
        DRONE_DEBUG = "true";
        VAULT_ADDR = "http://127.0.0.1:8200";
      };
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-vault-env.path;
        ExecStart = "${pkgs.nur.repos.xddxdd.drone-vault}/bin/drone-vault";
      };
    };
  };

  services.nginx.virtualHosts = {
    "ci.lantian.pub" = {
      listen = nginxHelper.listen443;
      locations = nginxHelper.addCommonLocationConf {
        "/" = {
          proxyPass = "http://127.0.0.1:13080";
          extraConfig = nginxHelper.locationProxyConf;
        };
      };
      extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
        + nginxHelper.commonVhostConf true;
    };
    "ci-github.lantian.pub" = {
      listen = nginxHelper.listen443;
      locations = nginxHelper.addCommonLocationConf {
        "/" = {
          proxyPass = "http://127.0.0.1:13081";
          extraConfig = nginxHelper.locationProxyConf;
        };
      };
      extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
        + nginxHelper.commonVhostConf true;
    };
  };
}
