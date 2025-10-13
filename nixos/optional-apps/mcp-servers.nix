{
  lib,
  inputs,
  config,
  utils,
  ...
}:
{
  options.lantian.mcp = {
    mcpServers = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
    toJSON = lib.mkOption {
      readOnly = true;
      default = utils.genJqSecretsReplacementSnippet {
        inherit (config.lantian.mcp) mcpServers;
      };
    };
    toAttrsWithEnvs = lib.mkOption {
      readOnly = true;
      default = lib.mapAttrs (
        n: v:
        lib.mapAttrs (
          an: av:
          if !builtins.isAttrs av then
            av
          else
            lib.mapAttrs (
              en: ev: if builtins.isAttrs ev && lib.hasAttr "_secret" ev then "\${${en}}" else ev
            ) av
        ) v
      ) config.lantian.mcp.mcpServers;
    };
    toCredentials = lib.mkOption {
      readOnly = true;
      default = builtins.listToAttrs (
        builtins.filter (v: v != null) (
          lib.flatten (
            lib.mapAttrsToList (
              n: v:
              lib.mapAttrsToList (
                en: ev:
                if builtins.isAttrs ev && lib.hasAttr "_secret" ev then lib.nameValuePair en ev._secret else null
              ) (v.env or { })
            ) config.lantian.mcp.mcpServers
          )
        )
      );
    };
  };

  config = {
    age.secrets.mcp-brave-search-api-key = {
      file = inputs.secrets + "/mcp-brave-search-api-key.age";
      mode = "0444";
    };
    age.secrets.mcp-google-maps-api-key = {
      file = inputs.secrets + "/mcp-google-maps-api-key.age";
      mode = "0444";
    };
    age.secrets.mcp-national-park-service-api-key = {
      file = inputs.secrets + "/mcp-national-park-service-api-key.age";
      mode = "0444";
    };

    lantian.mcp.mcpServers = {
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
      nixos = {
        command = "uvx";
        args = [ "mcp-nixos" ];
      };
    };
  };
}
