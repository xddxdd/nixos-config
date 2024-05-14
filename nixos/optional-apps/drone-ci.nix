{
  pkgs,
  LT,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./docker.nix
    ./drone-ci-secrets.nix
    ./postgresql.nix
  ];

  age.secrets = {
    drone-ci-env.file = inputs.secrets + "/drone-ci-env.age";
    drone-ci-file-secret-env.file = inputs.secrets + "/drone-ci-file-secret-env.age";
  };

  systemd.services = {
    drone = {
      wantedBy = [ "multi-user.target" ];
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
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-env.path;
        ExecStart = "${pkgs.drone}/bin/drone-server";
        RuntimeDirectory = "drone";
        User = "drone";
        Group = "drone";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        UMask = "007";
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
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://drone-file-secret.localhost";
      };
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-env.path;
        ExecStart = "${pkgs.drone-runner-docker}/bin/drone-runner-docker";
      };
    };
  };

  lantian.nginxVhosts = {
    "ci.lantian.pub" = {
      locations = {
        "/" = {
          proxyPass = "http://unix:/run/drone/drone.sock";
        };
      };

      sslCertificate = "lantian.pub_ecc";
      noIndex.enable = true;
    };

    "drone.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://unix:/run/drone/drone.sock";
        };
      };

      accessibleBy = "localhost";
      noIndex.enable = true;
    };
  };

  services.postgresql = {
    ensureDatabases = [ "drone" ];
    ensureUsers = [
      {
        name = "drone";
        ensureDBOwnership = true;
      }
    ];
  };

  users.users.drone = {
    group = "drone";
    isSystemUser = true;
  };
  users.groups.drone.members = [ "nginx" ];
}
