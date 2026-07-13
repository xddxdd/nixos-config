{
  lib,
  pkgs,
  LT,
  config,
  inputs,
  ...
}:
let
  picoclaw =
    inputs.llm-agents.packages."${pkgs.stdenv.hostPlatform.system}".picoclaw.overrideAttrs
      (old: {
        patches = (old.patches or [ ]) ++ [ ../../patches/picoclaw-disable-command-restrictions.patch ];
        doCheck = false;
        doInstallCheck = false;
      });
in
{
  imports = [ ../client-apps/mcp-servers.nix ];

  environment.systemPackages = [ picoclaw ];

  systemd.services.picoclaw = {
    description = "PicoClaw";
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.jq
      pkgs.nodejs
      pkgs.uv
    ];

    script =
      let
        mcpJsonFile = pkgs.writeText "picoclaw-mcp.json" (
          builtins.toJSON {
            mcpServers = lib.mapAttrs (k: v: v // { enabled = true; }) config.lantian.mcp.mcpServers;
          }
        );
      in
      ''
        CONFIG_DIR=$HOME/.picoclaw
        CONFIG_FILE=$CONFIG_DIR/config.json

        mkdir -p "$CONFIG_DIR"

        if [ ! -f "$CONFIG_FILE" ]; then
          echo '{}' > "$CONFIG_FILE"
        fi

        tmp_file=$(mktemp)
        jq --slurpfile mcp "${mcpJsonFile}" '.tools.mcp.servers = $mcp[0].mcpServers' "$CONFIG_FILE" > "$tmp_file"
        mv "$tmp_file" "$CONFIG_FILE"

        export PATH=/etc/profiles/per-user/lantian/bin:/run/current-system/sw/bin:$PATH
        exec ${lib.getExe picoclaw} gateway
      '';

    serviceConfig = LT.serviceHarden // {
      User = "lantian";
      Group = "lantian";

      MemoryDenyWriteExecute = false;
      ProtectHome = false;

      Restart = "always";
      RestartSec = "5";
    };
  };
}
