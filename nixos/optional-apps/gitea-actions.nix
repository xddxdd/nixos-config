{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  age.secrets.gitea-actions-token.file = inputs.secrets + "/gitea-actions-token.age";

  lantian.enablePodman = lib.mkForce true;

  services.gitea-actions-runner.instances.default = {
    enable = true;
    name = config.networking.hostName;
    url = "https://git.lantian.pub";
    labels = [
      "ubuntu-latest:docker://gitea/runner-images:ubuntu-latest"
      "ubuntu-22.04:docker://gitea/runner-images:ubuntu-22.04"
      "ubuntu-20.04:docker://gitea/runner-images:ubuntu-20.04"
    ];
    tokenFile = config.age.secrets.gitea-actions-token.path;

    settings = {
      log.level = "info";
      cache.dir = "/var/cache/gitea-actions";
      container = {
        network = "host";
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
