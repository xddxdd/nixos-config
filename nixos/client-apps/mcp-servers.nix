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
    # Disabled: common/mcp.yaml (MCP API keys) removed from nixos-secrets
    # (7bcc13f). Secret-backed MCP servers below are disabled until the
    # sops file is re-provisioned; re-enable entries via git history.
    # keep-sorted start block=yes
    #  sops.secrets.mcp-brave-search-api-key = {
    #    sopsFile = inputs.secrets + "/common/mcp.yaml";
    #    mode = "0444";
    #  };
    #  sops.secrets.mcp-composio-api-key = {
    #    sopsFile = inputs.secrets + "/common/mcp.yaml";
    #    mode = "0444";
    #  };
    #  sops.secrets.mcp-context7-api-key = {
    #    sopsFile = inputs.secrets + "/common/mcp.yaml";
    #    mode = "0444";
    #  };
    #  sops.secrets.mcp-exa-api-key = {
    #    sopsFile = inputs.secrets + "/common/mcp.yaml";
    #    mode = "0444";
    #  };
    #  sops.secrets.mcp-firecrawl-api-key = {
    #    sopsFile = inputs.secrets + "/common/mcp.yaml";
    #    mode = "0444";
    #  };
    #  sops.secrets.mcp-flightaware-api-key = {
    #    sopsFile = inputs.secrets + "/common/mcp.yaml";
    #    mode = "0444";
    #  };
    #  sops.secrets.mcp-gitea-api-key = {
    #    sopsFile = inputs.secrets + "/common/mcp.yaml";
    #    mode = "0444";
    #  };
    #  sops.secrets.mcp-google-maps-api-key = {
    #    sopsFile = inputs.secrets + "/common/mcp.yaml";
    #    mode = "0444";
    #  };
    #  sops.secrets.mcp-grok-api-key = {
    #    sopsFile = inputs.secrets + "/common/mcp.yaml";
    #    mode = "0444";
    #  };
    #  sops.secrets.mcp-national-park-service-api-key = {
    #    sopsFile = inputs.secrets + "/common/mcp.yaml";
    #    mode = "0444";
    #  };
    #  sops.secrets.mcp-tavily-api-key = {
    #    sopsFile = inputs.secrets + "/common/mcp.yaml";
    #    mode = "0444";
    #  };
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
