{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
let
  n8n-openai-bridge = pkgs.nur-xddxdd.n8n-openai-bridge.overrideAttrs (old: {
    inherit (LT.sources.n8n-openai-bridge-customized) version src;
    patches = (old.patches or [ ]) ++ [
      ../../../patches/n8n-openai-bridge-listen-localhost.patch
    ];
  });
in
{
  sops.secrets.n8n-openai-bridge-client-token = {
    # Use same key as uni-api for consistency
    sopsFile = inputs.secrets + "/uni-api/keys.yaml";
    key = "uni-api-admin-api-key";
    owner = "n8n-openai-bridge";
    group = "n8n-openai-bridge";
  };
  sops.secrets.n8n-openai-bridge-n8n-token = {
    sopsFile = inputs.secrets + "/n8n.yaml";
    owner = "n8n-openai-bridge";
    group = "n8n-openai-bridge";
  };

  systemd.services.n8n-openai-bridge = {
    description = "N8N OpenAI Bridge";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "sops-install-secrets.service"
    ];
    requires = [ "sops-install-secrets.service" ];

    environment = {
      PORT = LT.portStr.N8N-OpenAI-Bridge;
      DISABLE_RATE_LIMIT = "true";
      MODEL_LOADER_TYPE = "n8n-api";
      N8N_BASE_URL = "http://127.0.0.1:${LT.portStr.N8N}";
      AUTO_DISCOVERY_TAG = "n8n-openai-bridge";
      AUTO_DISCOVERY_POLL_INTERVAL = "300";
    };

    script = ''
      export BEARER_TOKEN=$(cat ${config.sops.secrets.n8n-openai-bridge-client-token.path})
      export N8N_API_BEARER_TOKEN=$(cat ${config.sops.secrets.n8n-openai-bridge-n8n-token.path})
      exec ${lib.getExe n8n-openai-bridge}
    '';

    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "3";
      MemoryDenyWriteExecute = lib.mkForce false;

      User = "n8n-openai-bridge";
      Group = "n8n-openai-bridge";
    };
  };

  users.users.n8n-openai-bridge = {
    group = "n8n-openai-bridge";
    isSystemUser = true;
  };
  users.groups.n8n-openai-bridge = { };

  lantian.nginxVhosts."n8n.xuyh0120.win".locations."/v1/" = {
    proxyPass = "http://127.0.0.1:${LT.portStr.N8N-OpenAI-Bridge}";
    proxyNoTimeout = true;
  };

  lantian.llm-providers = lib.mkBefore [
    {
      name = "n8n";
      baseURL = "http://127.0.0.1:${LT.portStr.N8N-OpenAI-Bridge}/v1/chat/completions";
      providerTags = [ "paid" ];
      apiKeyPath = config.sops.secrets."uni-api-admin-api-key".path;
      modelJsonFile = null;
    }
  ];
}
