{ config, inputs, ... }:
{
  sops.secrets.renovate-token.sopsFile = inputs.secrets + "/renovate.yaml";

  services.renovate = {
    enable = true;
    schedule = "hourly";
    credentials.RENOVATE_TOKEN = config.sops.secrets.renovate-token.path;
    settings = {
      platform = "gitea";
      endpoint = "https://git.lantian.pub/";
      autodiscover = true;
      binarySource = "global";
      onboarding = true;
      requireConfig = "required";
      onboardingConfig.extends = [ "config:recommended" ];
      automerge = false;
      allowScripts = false;
      allowPlugins = false;
      allowedCommands = [ ];
    };
  };

  systemd.services.renovate = {
    unitConfig.ConditionPathExists = config.services.renovate.credentials.RENOVATE_TOKEN;
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "1h";
      Restart = "no";
    };
  };

  systemd.timers.renovate.timerConfig = {
    RandomizedDelaySec = "5m";
    Persistent = true;
  };
}
