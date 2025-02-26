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
    # FIXME: wait for upstream task allocation improvement
    enable = false;

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

    path = [ py ];
    script = ''
      python3 -u ${LT.sources.sakura-share.src}/src/sakura_share_cli.py \
        --port ${LT.portStr.LlamaCpp} \
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
