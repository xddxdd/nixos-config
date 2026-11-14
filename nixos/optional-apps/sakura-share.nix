{
  config,
  lib,
  pkgs,
  LT,
  ...
}:
{
  sops.secrets.sakura-share-env = {
    sopsFile = LT.secret "sakura-share.yaml";
    owner = "sakura-share";
  };

  # Not enabled at boot; start manually with `systemctl start sakura-share`.
  systemd.services.sakura-share = {
    description = "Share client for sakura-share.one";
    after = [
      "network.target"
      "llama-swap.service"
    ];
    requires = [
      "network.target"
      "llama-swap.service"
    ];
    bindsTo = [ "llama-swap.service" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.sakura-share} --upstream http://127.0.0.1:${LT.portStr.LlamaSwap}/upstream/sakura-llm";
      Restart = "on-failure";
      # Wait 60s between connection attempts, otherwise batched tasks cause
      # inference inconsistency and fail validation
      RestartSec = 60;
      EnvironmentFile = config.sops.secrets.sakura-share-env.path;

      User = "sakura-share";
      Group = "sakura-share";
    };
  };

  lantian.harden.sakura-share = {
    enable = true;
    secret = true; # sops environment file below /run/secrets
  };

  users.users.sakura-share = {
    group = "sakura-share";
    isSystemUser = true;
  };
  users.groups.sakura-share = { };
}
