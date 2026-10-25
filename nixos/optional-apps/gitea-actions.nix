{
  lib,
  config,
  inputs,
  ...
}:
{
  sops.secrets.gitea-actions-token.sopsFile = inputs.secrets + "/gitea-actions.yaml";

  lantian.enablePodman = lib.mkForce true;

  services.gitea-actions-runner.instances.default = {
    enable = true;
    name = config.networking.hostName;
    url = "https://git.lantian.pub";
    labels = builtins.map (n: "${n}:docker://gitea/runner-images:${n}") [
      "ubuntu-latest"
      "ubuntu-latest-slim"
      "ubuntu-latest-full"
    ];
    tokenFile = config.sops.secrets.gitea-actions-token.path;

    settings = {
      log.level = "info";
      cache.dir = "/var/cache/gitea-actions";
      container = {
        network = "bridge";
        docker_host = "-";
        valid_volumes = [ "/nix/sync-servers" ];
      };
    };
  };

  systemd.services.gitea-runner-default.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = lib.mkForce "gitea-actions";
    Group = lib.mkForce "gitea-actions";

    CacheDirectory = "gitea-actions";
    RestartSec = lib.mkForce "5s";
  };
  lantian.harden.gitea-runner-default = {
    enable = true;
    secret = true; # Docker/podman socket
  };

  users.users.gitea-actions = {
    group = "gitea-actions";
    isSystemUser = true;
  };
  users.groups.gitea-actions = { };
}
