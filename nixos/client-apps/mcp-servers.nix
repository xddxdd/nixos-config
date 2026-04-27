{
  pkgs,
  lib,
  inputs,
  config,
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
    sops.secrets.mcp-google-maps-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-national-park-service-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };

    lantian.mcp.mcpServers = {
      # keep-sorted start block=yes
      brave-search = {
        command = toString (
          pkgs.writeShellScript "mcp-brave-search" ''
            export BRAVE_API_KEY=$(cat "${config.sops.secrets.mcp-brave-search-api-key.path}")
            exec ${pkgs.nodejs}/bin/npx -y @modelcontextprotocol/server-brave-search
          ''
        );
        alwaysAllow = [
          "brave_web_search"
          "brave_local_search"
        ];
      };
      browser-control-mcp = {
        command = toString (
          pkgs.writeShellScript "mcp-browser-control" ''
            export EXTENSION_SECRET=$(cat '/home/lantian/.mozilla/firefox/lantian/browser-extension-data/{6ba257e0-fbce-4d50-8471-25de7f024c1e}/storage.js' | ${lib.getExe pkgs.jq} -r .config.secret)
            exec ${lib.getExe pkgs.nur-xddxdd.browser-control-mcp}
          ''
        );
        alwaysAllow = [
          "open-browser-tab"
          "close-browser-tabs"
          "get-list-of-open-tabs"
          "get-recent-browser-history"
          "get-tab-web-content"
          "reorder-browser-tabs"
          "find-highlight-in-browser-tab"
          "group-browser-tabs"
        ];
      };
      context7 = {
        command = toString (
          pkgs.writeShellScript "mcp-context7" ''
            export CONTEXT7_API_KEY=$(cat "${config.sops.secrets.mcp-context7-api-key.path}")
            exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp@latest
          ''
        );
        alwaysAllow = [
          "resolve-library-id"
          "query-docs"
        ];
      };
      fetch = {
        command = "uvx";
        args = [ "mcp-server-fetch" ];
        alwaysAllow = [
          "fetch"
        ];
      };
      google-maps = {
        command = toString (
          pkgs.writeShellScript "mcp-google-maps" ''
            export GOOGLE_MAPS_API_KEY=$(cat "${config.sops.secrets.mcp-google-maps-api-key.path}")
            exec ${pkgs.nodejs}/bin/npx -y @modelcontextprotocol/server-google-maps
          ''
        );
        alwaysAllow = [
          "maps_geocode"
          "maps_reverse_geocode"
          "maps_search_places"
          "maps_place_details"
          "maps_distance_matrix"
          "maps_elevation"
          "maps_directions"
        ];
      };
      national-park-service = {
        command = toString (
          pkgs.writeShellScript "mcp-national-park-service" ''
            export NPS_API_KEY=$(cat "${config.sops.secrets.mcp-national-park-service-api-key.path}")
            exec ${pkgs.nodejs}/bin/npx -y mcp-server-nationalparks
          ''
        );
        alwaysAllow = [
          "findParks"
          "getParkDetails"
          "getAlerts"
          "getVisitorCenters"
          "getCampgrounds"
          "getEvents"
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
        alwaysAllow = [
          "searxng_web_search"
          "web_url_read"
        ];
      };
      time = {
        command = "uvx";
        args = [
          "mcp-server-time"
          "--local-timezone=${config.time.timeZone}"
        ];
        alwaysAllow = [
          "get_current_time"
          "convert_time"
        ];
      };
      # keep-sorted end
    };
  };
}
