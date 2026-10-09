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
    # keep-sorted start block=yes
    sops.secrets.mcp-brave-search-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-composio-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-context7-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-exa-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-firecrawl-api-key = {
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
    sops.secrets.mcp-grok-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-national-park-service-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    sops.secrets.mcp-tavily-api-key = {
      sopsFile = inputs.secrets + "/common/mcp.yaml";
      mode = "0444";
    };
    # keep-sorted end

    lantian.mcp.mcpServers = {
      # keep-sorted start block=yes
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
      akasha-terminal = {
        type = "streamable-http";
        url = "https://agent.zlb.ink/api/mcp/";
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
      composio = {
        command = toString (
          pkgs.writeShellScript "mcp-composio" ''
            exec ${lib.getExe pkgs.mcp-proxy} \
              -H x-consumer-api-key "$(cat ${config.sops.secrets.mcp-composio-api-key.path})" \
              --transport streamablehttp \
              "https://connect.composio.dev/mcp"
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
        type = "streamable-http";
        url = "https://mcp.deepwiki.com/mcp";
      };
      exa = {
        command = toString (
          pkgs.writeShellScript "mcp-exa" ''
            exec ${lib.getExe pkgs.mcp-proxy} \
              -H Authorization "Bearer $(cat ${config.sops.secrets.mcp-exa-api-key.path})" \
              --transport streamablehttp \
              "https://mcp.exa.ai/mcp?tools=web_search_exa,web_fetch_exa,web_search_advanced_exa"
          ''
        );
      };
      firecrawl = {
        command = toString (
          pkgs.writeShellScript "mcp-firecrawl" ''
            export FIRECRAWL_API_KEY=$(cat "${config.sops.secrets.mcp-firecrawl-api-key.path}")
            exec ${pkgs.nodejs}/bin/npx -y firecrawl-mcp
          ''
        );
      };
      flightaware = {
        command = toString (
          pkgs.writeShellScript "mcp-flightaware" ''
            export AEROAPI_KEY=$(cat "${config.sops.secrets.mcp-flightaware-api-key.path}")
            export HISHEL_CACHE_PATH=/tmp/mcp-flightaware-cache.db
            exec ${pkgs.uv}/bin/uvx '--with=mcp<2' flightaware-mcp
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
      mdn = {
        type = "streamable-http";
        url = "https://mcp.mdn.mozilla.net/";
      };
      national-park-service = {
        command = toString (
          pkgs.writeShellScript "mcp-national-park-service" ''
            export NPS_API_KEY=$(cat "${config.sops.secrets.mcp-national-park-service-api-key.path}")
            exec ${pkgs.nodejs}/bin/npx -y mcp-server-nationalparks
          ''
        );
      };
      nixos = {
        command = "uvx";
        args = [
          "--with=mcp<2"
          "mcp-nixos"
        ];
      };
      tavily = {
        command = toString (
          pkgs.writeShellScript "mcp-tavily" ''
            exec ${lib.getExe pkgs.mcp-proxy} \
              -H Authorization "Bearer $(cat ${config.sops.secrets.mcp-tavily-api-key.path})" \
              --transport streamablehttp \
              "https://mcp.tavily.com/mcp"
          ''
        );
      };
      time = {
        command = lib.getExe pkgs.mcp-server-time;
        args = [
          "--local-timezone=${config.time.timeZone}"
        ];
      };
      weather = {
        command = "npx";
        args = [
          "-y"
          "@dangahagan/weather-mcp@latest"
        ];
        env = {
          ENABLED_TOOLS = "full";
        };
      };
      # keep-sorted end
    }
    // lib.optionalAttrs (config.networking.hostName == "lt-hp-omen") {
      browseros = {
        type = "streamable-http";
        url = "http://127.0.0.1:9000/mcp";
      };
    }
    // lib.optionalAttrs config.virtualisation.libvirtd.enable {
      libvirt = {
        command = lib.getExe pkgs.mcp-libvirt;
      };
    };
  };
}
