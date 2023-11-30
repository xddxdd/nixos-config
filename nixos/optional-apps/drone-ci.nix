{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  droneSecretsAttrs =
    lib.genAttrs
    [
      "drone/git-netrc"
      "drone/github-token"
      "drone/ssh-id-ed25519"
      "drone/ssh-id-rsa"
      "drone/telegram-target"
      "drone/telegram-token"
    ]
    (k: {
      file = inputs.secrets + "/${k}.age";
      owner = "container";
      group = "container";
    });
in {
  imports = [
    ./docker.nix
    ./postgresql.nix
  ];

  age.secrets =
    droneSecretsAttrs
    // {
      drone-ci-env.file = inputs.secrets + "/drone-ci-env.age";
      drone-ci-github-env.file = inputs.secrets + "/drone-ci-github-env.age";
      drone-ci-file-secret-env.file = inputs.secrets + "/drone-ci-file-secret-env.age";
    };

  systemd.services = {
    drone = {
      wantedBy = ["multi-user.target"];
      environment = {
        DRONE_DATABASE_DRIVER = "postgres";
        DRONE_DATABASE_DATASOURCE = "host=/run/postgresql user=drone dbname=drone";
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
      serviceConfig =
        LT.serviceHarden
        // {
          Type = "simple";
          Restart = "always";
          RestartSec = "3";
          EnvironmentFile = config.age.secrets.drone-ci-env.path;
          ExecStart = "${pkgs.drone}/bin/drone-server";
          RuntimeDirectory = "drone";
          User = "drone";
          Group = "drone";
          AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
          CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
          UMask = "007";
        };
    };
    drone-github = {
      wantedBy = ["multi-user.target"];
      environment = {
        DRONE_DATABASE_DRIVER = "postgres";
        DRONE_DATABASE_DATASOURCE = "host=/run/postgresql user=drone-github dbname=drone-github";
        DRONE_JSONNET_ENABLED = "true";
        DRONE_REGISTRATION_CLOSED = "true";
        DRONE_SERVER_HOST = "ci-github.lantian.pub";
        DRONE_SERVER_PORT = ":80";
        DRONE_SERVER_UNIX = "/run/drone-github/drone-github.sock";
        DRONE_SERVER_PROTO = "https";
        DRONE_STARLARK_ENABLED = "true";
        DRONE_USER_CREATE = "username:xddxdd,admin:true";
      };
      serviceConfig =
        LT.serviceHarden
        // {
          Type = "simple";
          Restart = "always";
          RestartSec = "3";
          EnvironmentFile = config.age.secrets.drone-ci-github-env.path;
          ExecStart = "${pkgs.drone}/bin/drone-server";
          RuntimeDirectory = "drone-github";
          User = "drone-github";
          Group = "drone-github";
          AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
          CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
          UMask = "007";
        };
    };

    drone-docker = {
      wantedBy = ["multi-user.target"];
      environment = {
        DOCKER_HOST = "unix:///run/docker-vm/docker.sock";
        # Make socket bind fail, this won't affect runner functionality
        DRONE_HTTP_BIND = "255.255.255.255:65535";
        DRONE_RPC_HOST = "drone.localhost";
        DRONE_RPC_PROTO = "http";
        DRONE_RUNNER_CAPACITY = "4";
        DRONE_RUNNER_NAME = "drone-docker";
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://drone-file-secret.localhost";
      };
      serviceConfig =
        LT.serviceHarden
        // {
          Type = "simple";
          Restart = "always";
          RestartSec = "3";
          EnvironmentFile = config.age.secrets.drone-ci-env.path;
          ExecStart = "${pkgs.drone-runner-docker}/bin/drone-runner-docker";
        };
    };
    drone-docker-github = {
      wantedBy = ["multi-user.target"];
      environment = {
        DOCKER_HOST = "unix:///run/docker-vm/docker.sock";
        # Make socket bind fail, this won't affect runner functionality
        DRONE_HTTP_BIND = "255.255.255.255:65535";
        DRONE_RPC_HOST = "drone-github.localhost";
        DRONE_RPC_PROTO = "http";
        DRONE_RUNNER_CAPACITY = "4";
        DRONE_RUNNER_NAME = "drone-docker";
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://drone-file-secret.localhost";
      };
      serviceConfig =
        LT.serviceHarden
        // {
          Type = "simple";
          Restart = "always";
          RestartSec = "3";
          EnvironmentFile = config.age.secrets.drone-ci-github-env.path;
          ExecStart = "${pkgs.drone-runner-docker}/bin/drone-runner-docker";
          DynamicUser = true;
        };
    };

    drone-file-secret = {
      wantedBy = ["multi-user.target"];
      environment = {
        DRONE_BASE_PATH = "/run/agenix/drone";
        DRONE_UNIX_SOCKET = "/run/drone-file-secret/drone-file-secret.sock";
      };
      serviceConfig =
        LT.serviceHarden
        // {
          Type = "simple";
          Restart = "always";
          RestartSec = "3";
          EnvironmentFile = config.age.secrets.drone-ci-file-secret-env.path;
          ExecStart = "${pkgs.drone-file-secret}/bin/drone-file-secret";
          RuntimeDirectory = "drone-file-secret";
          User = "container";
          Group = "container";
          UMask = "007";
        };
    };
  };

  services.nginx.virtualHosts = {
    "ci.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://unix:/run/drone/drone.sock";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig =
        LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };

    "drone.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://unix:/run/drone/drone.sock";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig =
        LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost null;
    };

    "ci-github.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://unix:/run/drone-github/drone-github.sock";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig =
        LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };

    "drone-github.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://unix:/run/drone-github/drone-github.sock";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig =
        LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost null;
    };

    "drone-file-secret.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://unix:/run/drone-file-secret/drone-file-secret.sock";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig =
        LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost null;
    };
  };

  services.postgresql = {
    ensureDatabases = ["drone" "drone-github"];
    ensureUsers = [
      {
        name = "drone";
        ensureDBOwnership = true;
      }
      {
        name = "drone-github";
        ensureDBOwnership = true;
      }
    ];
  };

  users.users.drone = {
    group = "drone";
    isSystemUser = true;
  };
  users.users.drone-github = {
    group = "drone-github";
    isSystemUser = true;
  };
  users.groups.drone.members = ["nginx"];
  users.groups.drone-github.members = ["nginx"];
}
