{
  lib,
  pkgs,
  LT,
  ...
}:
let
  # Upstream llm-agents.nix removed picoclaw; repackage the afjcjsbx fork locally
  picoclaw = pkgs.callPackage ../../pkgs/picoclaw { };
in
{
  imports = [ ../client-apps/mcp-servers.nix ];

  environment.systemPackages = [ picoclaw ];

  systemd.services.picoclaw = {
    description = "PicoClaw";
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.nodejs
      pkgs.uv
    ];

    script = ''
      CONFIG_DIR=$HOME/.picoclaw
      CONFIG_FILE=$CONFIG_DIR/config.json

      mkdir -p "$CONFIG_DIR"

      if [ ! -f "$CONFIG_FILE" ]; then
        echo '{}' > "$CONFIG_FILE"
      fi

      # Remove leftover PID file
      rm -f $CONFIG_DIR/.picoclaw.pid

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
