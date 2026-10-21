{
  pkgs,
  lib,
  inputs,
  config,
  LT,
  ...
}:
let
  # mcp.yaml is encrypted only for this host and the user recovery key.
  credentialed = config.networking.hostName == "lt-hp-omen";
in
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
    sops.secrets =
      lib.genAttrs
        (map (name: "mcp-${name}-api-key") (
          lib.optionals credentialed [
            "composio"
            "context7"
            "exa"
            "firecrawl"
            "flightaware"
            "gitea"
            "google-maps"
            "national-park-service"
            "tavily"
          ]
        ))
        (_: {
          sopsFile = inputs.secrets + "/mcp.yaml";
          owner = "lantian";
          mode = "0400";
        });

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
      deepwiki = {
        type = "streamable-http";
        url = "https://mcp.deepwiki.com/mcp";
      };
      mdn = {
        type = "streamable-http";
        url = "https://mcp.mdn.mozilla.net/";
      };
      nixos = {
        command = "uvx";
        args = [
          "--with=mcp<2"
          "mcp-nixos"
        ];
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
    // lib.optionalAttrs credentialed {
      browseros = {
        type = "streamable-http";
        url = "http://127.0.0.1:9000/mcp";
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
      gitea = {
        command = toString (
          pkgs.writeShellScript "mcp-gitea" ''
            export GITEA_HOST=https://git.lantian.pub
            export GITEA_ACCESS_TOKEN=$(cat "${config.sops.secrets.mcp-gitea-api-key.path}")
            exec ${lib.getExe pkgs.gitea-mcp-server} -t stdio
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
      national-park-service = {
        command = toString (
          pkgs.writeShellScript "mcp-national-park-service" ''
            export NPS_API_KEY=$(cat "${config.sops.secrets.mcp-national-park-service-api-key.path}")
            exec ${pkgs.nodejs}/bin/npx -y mcp-server-nationalparks
          ''
        );
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
    }
    // lib.optionalAttrs config.virtualisation.libvirtd.enable {
      libvirt = {
        command = lib.getExe pkgs.mcp-libvirt;
      };
    };
  };
}
