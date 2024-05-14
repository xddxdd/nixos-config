{
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  age.secrets.gitea-actions-token.file = inputs.secrets + "/gitea-actions-token.age";

  lantian.enablePodman = lib.mkForce true;

  services.gitea-actions-runner.instances.default = {
    enable = true;
    name = config.networking.hostName;
    url = "https://git.lantian.pub";
    labels = builtins.map (n: "${n}:docker://gitea/runner-images:${n}") [
      "ubuntu-latest"
      "ubuntu-22.04"
      "ubuntu-20.04"
      "ubuntu-latest-slim"
      "ubuntu-22.04-slim"
      "ubuntu-20.04-slim"
      "ubuntu-latest-full"
      "ubuntu-22.04-full"
      "ubuntu-20.04-full"
    ];
    tokenFile = config.age.secrets.gitea-actions-token.path;

    settings = {
      log.level = "info";
      cache.dir = "/var/cache/gitea-actions";
      container = {
        network = "bridge";
        docker_host = "-";
        valid_volumes = [ "/nix/persistent/sync-servers" ];
      };
    };
  };

  systemd.services.gitea-runner-default.serviceConfig = LT.serviceHarden // {
    DynamicUser = lib.mkForce false;
    User = lib.mkForce "gitea-actions";
    Group = lib.mkForce "gitea-actions";

    CacheDirectory = "gitea-actions";
  };

  users.users.gitea-actions = {
    group = "gitea-actions";
    isSystemUser = true;
  };
  users.groups.gitea-actions = { };
}
