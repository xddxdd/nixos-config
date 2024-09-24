{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  age.secrets =
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

  systemd.services = {
    drone-file-secret = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        DRONE_BASE_PATH = "/run/agenix/drone";
        DRONE_UNIX_SOCKET = "/run/drone-file-secret/drone-file-secret.sock";
      };
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        EnvironmentFile = config.age.secrets.drone-ci-file-secret-env.path;
        ExecStart = "${pkgs.nur-xddxdd.drone-file-secret}/bin/drone-file-secret";
        RuntimeDirectory = "drone-file-secret";
        User = "container";
        Group = "container";
        UMask = "007";
      };
    };
  };

  lantian.nginxVhosts = {
    "drone-file-secret.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://unix:/run/drone-file-secret/drone-file-secret.sock";
        };
      };

      accessibleBy = "localhost";
      noIndex.enable = true;
    };
  };
}
