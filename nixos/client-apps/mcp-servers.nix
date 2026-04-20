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

    sops.templates.mcp-brave-search-cmd = {
      content = ''
        #!/bin/sh
        export BRAVE_API_KEY=$(cat "${config.sops.secrets.mcp-brave-search-api-key.path}")
        exec ${pkgs.nodejs}/bin/npx -y @modelcontextprotocol/server-brave-search
      '';
      mode = "0555";
    };
    sops.templates.mcp-context7-cmd = {
      content = ''
        #!/bin/sh
        export CONTEXT7_API_KEY=$(cat "${config.sops.secrets.mcp-context7-api-key.path}")
        exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp@latest
      '';
      mode = "0555";
    };
    sops.templates.mcp-google-maps-cmd = {
      content = ''
        #!/bin/sh
        export GOOGLE_MAPS_API_KEY=$(cat "${config.sops.secrets.mcp-google-maps-api-key.path}")
        exec ${pkgs.nodejs}/bin/npx -y @modelcontextprotocol/server-google-maps
      '';
      mode = "0555";
    };
    sops.templates.mcp-national-park-service-cmd = {
      content = ''
        #!/bin/sh
        export NPS_API_KEY=$(cat "${config.sops.secrets.mcp-national-park-service-api-key.path}")
        exec ${pkgs.nodejs}/bin/npx -y mcp-server-nationalparks
      '';
      mode = "0555";
    };

    lantian.mcp.mcpServers = {
      # keep-sorted start block=yes
      brave-search = {
        command = lib.getExe pkgs.bash;
        args = [ config.sops.templates.mcp-brave-search-cmd.path ];
        alwaysAllow = [
          "brave_web_search"
          "brave_local_search"
        ];
      };
      context7 = {
        command = lib.getExe pkgs.bash;
        args = [ config.sops.templates.mcp-context7-cmd.path ];
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
        command = lib.getExe pkgs.bash;
        args = [ config.sops.templates.mcp-google-maps-cmd.path ];
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
        command = lib.getExe pkgs.bash;
        args = [ config.sops.templates.mcp-national-park-service-cmd.path ];
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
