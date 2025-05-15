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
    drone-ci-github-env.file = inputs.secrets + "/drone-ci-github-env.age";
    drone-ci-file-secret-env.file = inputs.secrets + "/drone-ci-file-secret-env.age";
  };

  systemd.services = {
    drone-github = {
      wantedBy = [ "multi-user.target" ];
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
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-github-env.path;
        ExecStart = "${pkgs.drone}/bin/drone-server";
        RuntimeDirectory = "drone-github";
        User = "drone-github";
        Group = "drone-github";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        UMask = "007";
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
        DRONE_SECRET_PLUGIN_ENDPOINT = "http://drone-file-secret.localhost";
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
  };

  lantian.nginxVhosts = {
    "ci-github.lantian.pub" = {
      locations = {
        "/" = {
          proxyPass = "http://unix:/run/drone-github/drone-github.sock";
        };
      };

      sslCertificate = "lantian.pub";
      noIndex.enable = true;
    };

    "drone-github.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://unix:/run/drone-github/drone-github.sock";
        };
      };

      accessibleBy = "localhost";
      noIndex.enable = true;
    };
  };

  services.postgresql = {
    ensureDatabases = [ "drone-github" ];
    ensureUsers = [
      {
        name = "drone-github";
        ensureDBOwnership = true;
      }
    ];
  };

  users.users.drone-github = {
    group = "drone-github";
    isSystemUser = true;
  };
  users.groups.drone-github.members = [ "nginx" ];
}
