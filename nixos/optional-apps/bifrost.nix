{
  pkgs,
  LT,
  lib,
  utils,
  config,
  ...
}:
let
  bifrostConfig = {
    client = {
      drop_excess_requests = false;
      enable_logging = true;
    };
    providers = builtins.listToAttrs (
      builtins.map (
        p:
        lib.nameValuePair p.name {
          keys = [
            {
              name = "${p.name}-1";
              value = if p.apiKeyPath != null then { _secret = p.apiKeyPath; } else "sk-unused";
              models =
                if p.modelJsonFile != null then builtins.attrNames (lib.importJSON p.modelJsonFile) else [ "*" ];
              weight = 1.0;
            }
          ];
          custom_provider_config.base_provider_type = p.bifrostType;
          network_config = lib.optionalAttrs (p.bifrostType == "openai") {
            base_url = lib.removeSuffix "/v1/chat/completions" p.baseURL;
          };
        }
      ) (builtins.filter (p: p.bifrostType != null) config.lantian.llm-providers)
    );
    config_store.enabled = false;
    logs_store.enabled = false;
  };
in
{
  systemd.services.bifrost = {
    description = "Bifrost Server";
    after = [
      "network.target"
      "sops-install-secrets.service"
    ];
    requires = [ "sops-install-secrets.service" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      ${utils.genJqSecretsReplacementSnippet bifrostConfig "config.json"}
      exec ${lib.getExe pkgs.nur-xddxdd.bifrost} \
        --app-dir "$(pwd)" \
        --host "127.0.0.1" \
        --port "${LT.portStr.Bifrost}"
    '';

    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "3";

      StateDirectory = "bifrost";
      WorkingDirectory = "/var/lib/bifrost";

      User = "bifrost";
      Group = "ai-gateways";

      MemoryDenyWriteExecute = lib.mkForce false;
      SystemCallFilter = lib.mkForce [ ];
    };
  };

  users.users.bifrost = {
    group = "ai-gateways";
    isSystemUser = true;
  };
  users.groups.ai-gateways.members = [ "nginx" ];

  lantian.nginxVhosts = {
    "bifrost.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Bifrost}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
      accessibleBy = "private";
    };
    "bifrost.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Bifrost}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
