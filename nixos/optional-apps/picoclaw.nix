{
  lib,
  pkgs,
  LT,
  config,
  ...
}:
let
  picoclaw = pkgs.llm-agents.picoclaw.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace pkg/tools/shell.go \
        --replace-fail "t.guardCommand(command, cwd)" '""'
    '';
    doCheck = false;
    doInstallCheck = false;
  });
in
{
  imports = [ ../client-apps/mcp-servers.nix ];

  environment.systemPackages = [
    pkgs.github-cli
    picoclaw
  ];

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
            mcpServers = lib.mapAttrs (
              k: v: (lib.removeAttrs v [ "alwaysAllow" ]) // { enabled = true; }
            ) config.lantian.mcp.mcpServers;
          }
        );
      in
      ''
        CONFIG_DIR=/var/lib/picoclaw/.picoclaw
        CONFIG_FILE=$CONFIG_DIR/config.json

        mkdir -p "$CONFIG_DIR"

        if [ ! -f "$CONFIG_FILE" ]; then
          echo '{}' > "$CONFIG_FILE"
        fi

        tmp_file=$(mktemp)
        jq --slurpfile mcp "${mcpJsonFile}" '.tools.mcp.servers = $mcp[0].mcpServers' "$CONFIG_FILE" > "$tmp_file"
        mv "$tmp_file" "$CONFIG_FILE"

        export PATH=/run/current-system/sw/bin:$PATH
        exec ${lib.getExe picoclaw} gateway
      '';

    serviceConfig = LT.serviceHarden // {
      User = "picoclaw";
      Group = "picoclaw";

      MemoryDenyWriteExecute = false;
      StateDirectory = "picoclaw";

      Restart = "always";
      RestartSec = "5";
    };
  };

  users.users.picoclaw = {
    group = "picoclaw";
    isSystemUser = true;
    home = "/var/lib/picoclaw";
  };
  users.groups.picoclaw = { };
}
