{
  LT,
  pkgs,
  lib,
  config,
  utils,
  inputs,
  ...
}:
let
  cfg = {
    mcpServers = {
      fetch = {
        command = "uvx";
        args = [ "mcp-server-fetch" ];
      };
      time = {
        command = "uvx";
        args = [
          "mcp-server-time"
          "--local-timezone=${config.time.timeZone}"
        ];
      };
      searxng = {
        command = "npx";
        args = [
          "-y"
          "mcp-searxng"
        ];
        env = {
          SEARXNG_URL = "https://searx.xuyh0120.win";
        };
      };
      context7 = {
        command = "npx";
        args = [
          "-y"
          "@upstash/context7-mcp@latest"
        ];
      };
      brave-search = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-brave-search"
        ];
        env = {
          BRAVE_API_KEY = {
            _secret = config.age.secrets.mcp-brave-search-api-key.path;
          };
        };
      };
      google-maps = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-google-maps"
        ];
        env = {
          GOOGLE_MAPS_API_KEY = {
            _secret = config.age.secrets.mcp-google-maps-api-key.path;
          };
        };
      };
      national-park-service = {
        command = "npx";
        args = [
          "-y"
          "mcp-server-nationalparks"
        ];
        env = {
          NPS_API_KEY = {
            _secret = config.age.secrets.mcp-national-park-service-api-key.path;
          };
        };
      };
    };
  };
in
{
  age.secrets.mcp-brave-search-api-key.file = inputs.secrets + "/mcp-brave-search-api-key.age";
  age.secrets.mcp-google-maps-api-key.file = inputs.secrets + "/mcp-google-maps-api-key.age";
  age.secrets.mcp-national-park-service-api-key.file =
    inputs.secrets + "/mcp-national-park-service-api-key.age";

  virtualisation.oci-containers.containers.mcpo = {
    extraOptions = [
      "--pull=always"
    ];
    ports = [
      "127.0.0.1:${LT.portStr.Mcpo}:${LT.portStr.Mcpo}"
    ];
    cmd = [
      "--port=${LT.portStr.Mcpo}"
      "--config=/config.json"
    ];
    image = "ghcr.io/open-webui/mcpo:latest";
    volumes = [ "/run/mcpo/config.json:/config.json" ];
  };

  systemd.services.podman-mcpo = {
    path = with pkgs; [ curl ];
    preStart = lib.mkBefore ''
      ${utils.genJqSecretsReplacementSnippet cfg "/run/mcpo/config.json"}
    '';
    postStart = ''
      curl \
        --fail \
        --retry 100 \
        --retry-delay 5 \
        --retry-max-time 300 \
        --retry-all-errors \
        http://127.0.0.1:${LT.portStr.Mcpo}/openapi.json
    '';
    serviceConfig.RuntimeDirectory = "mcpo";
  };

  lantian.nginxVhosts."mcpo.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Mcpo}";
        proxyNoTimeout = true;
        extraConfig = ''
          sub_filter_types *;
          sub_filter_once off;
          sub_filter 'http://0.0.0.0:${LT.portStr.Mcpo}' 'https://mcpo.${config.networking.hostName}.xuyh0120.win';
        '';
      };
    };

    accessibleBy = "private";
    sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
