{
  pkgs,
  LT,
  inputs,
  config,
  ...
}:
let
  py = pkgs.python3.withPackages (
    ps: with ps; [
      requests
      aiohttp
    ]
  );
in
{
  age.secrets.sakura-share-env.file = inputs.secrets + "/sakura-share-env.age";

  systemd.services.sakura-share = {
    description = "Share client for sakura-share.one";
    after = [
      "network.target"
      # "llama-cpp.service"
      "podman-sglang-sakura-llm.service"
    ];
    requires = [
      "network.target"
      # "llama-cpp.service"
      "podman-sglang-sakura-llm.service"
    ];
    wantedBy = [ "multi-user.target" ];

    path = [
      py
      pkgs.curl
    ];
    script = ''
      curl \
        --fail \
        --retry 100 \
        --retry-delay 5 \
        --retry-max-time 300 \
        --retry-all-errors \
        http://127.0.0.1:${LT.portStr.SakuraLLM}/health

      python3 -u ${LT.sources.sakura-share.src}/src/sakura_share_cli.py \
        --port ${LT.portStr.SakuraLLM} \
        --tg-token "$TG_TOKEN" \
        --action start \
        --mode ws
    '';

    serviceConfig = LT.serviceHarden // {
      Restart = "on-failure";
      RestartSec = 10;
      EnvironmentFile = config.age.secrets.sakura-share-env.path;

      User = "llama-cpp";
      Group = "llama-cpp";
    };
  };
}
