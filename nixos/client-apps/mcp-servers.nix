{
  pkgs,
  lib,
  inputs,
  config,
  LT,
  ...
}:
{
  options.lantian.mcp = {
    mcpServers = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
    mcpJsonFile = lib.mkOption {
      readOnly = true;
      default = pkgs.writeText "mcp.json" (
        builtins.toJSON {
          inherit (config.lantian.mcp) mcpServers;
        }
      );
    };
  };

  config = {
    sops.secrets.mcp-brave-search-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-context7-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-flightaware-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-google-maps-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-national-park-service-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-grok-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-tavily-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };

    lantian.mcp.mcpServers = {
      # keep-sorted start block=yes
      adsb-lol = {
        command = "uvx";
        args = [
          "awslabs.openapi-mcp-server@latest"
          "--api-name=adsb.lol"
          "--api-url=https://api.adsb.lol"
          "--spec-url=https://api.adsb.lol/api/openapi.json"
        ];
      };
      airplanes-live = {
        command =
          let
            py = pkgs.python3.withPackages (ps: [
              ps.mcp
              ps.fastmcp
              ps.httpx
            ]);
          in
          toString (
            pkgs.writeShellScript "mcp-airplanes-live" ''
              exec ${py}/bin/python ${LT.sources.airplanes-live-mcp.src}/airplane_server.py
            ''
          );
      };
      brave-search = {
        command = toString (
          pkgs.writeShellScript "mcp-brave-search" ''
            export BRAVE_API_KEY=$(cat "${config.sops.secrets.mcp-brave-search-api-key.path}")
            exec ${pkgs.nodejs}/bin/npx -y @modelcontextprotocol/server-brave-search
          ''
        );
      };
      caldav = {
        command = toString (
          pkgs.writeShellScript "mcp-caldav" ''
            export CALDAV_BASE_URL=https://cal.xuyh0120.win
            export CALDAV_USERNAME=lantian
            export CALDAV_PASSWORD=$(cat "${config.sops.secrets.default-pw.path}")
            exec ${pkgs.nodejs}/bin/npx -y caldav-mcp
          ''
        );
      };
      context7 = {
        command = toString (
          pkgs.writeShellScript "mcp-context7" ''
            export CONTEXT7_API_KEY=$(cat "${config.sops.secrets.mcp-context7-api-key.path}")
            exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp@latest
          ''
        );
      };
      deepwiki = {
        type = "remote";
        url = "https://mcp.deepwiki.com/mcp";
      };
      flightaware = {
        command = toString (
          pkgs.writeShellScript "mcp-flightaware" ''
            export AEROAPI_KEY=$(cat "${config.sops.secrets.mcp-flightaware-api-key.path}")
            export HISHEL_CACHE_PATH=/tmp/mcp-flightaware-cache.db
            exec ${pkgs.uv}/bin/uvx flightaware-mcp
          ''
        );
      };
      google-maps = {
        command = toString (
          pkgs.writeShellScript "mcp-google-maps" ''
            export GOOGLE_MAPS_API_KEY=$(cat "${config.sops.secrets.mcp-google-maps-api-key.path}")
            exec ${pkgs.nodejs}/bin/npx -y @modelcontextprotocol/server-google-maps
          ''
        );
      };
      grok-search-rs = {
        command = toString (
          pkgs.writeShellScript "mcp-grok-search-rs" ''
            export GROK_SEARCH_API_KEY=$(cat "${config.sops.secrets.mcp-grok-api-key.path}")
            export GROK_SEARCH_MODEL=grok-4.3-fast-reasoning
            export GROK_SEARCH_WEB_SEARCH=true
            export GROK_SEARCH_X_SEARCH=true
            export TAVILY_API_KEY=$(cat "${config.sops.secrets.mcp-tavily-api-key.path}")
            exec ${lib.getExe pkgs.nur-xddxdd.grok-search-rs}
          ''
        );
      };
      national-park-service = {
        command = toString (
          pkgs.writeShellScript "mcp-national-park-service" ''
            export NPS_API_KEY=$(cat "${config.sops.secrets.mcp-national-park-service-api-key.path}")
            exec ${pkgs.nodejs}/bin/npx -y mcp-server-nationalparks
          ''
        );
      };
      time = {
        command = "uvx";
        args = [
          "mcp-server-time"
          "--local-timezone=${config.time.timeZone}"
        ];
      };
      # keep-sorted end
    };
  };
}
