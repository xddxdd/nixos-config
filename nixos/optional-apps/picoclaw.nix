{
  lib,
  pkgs,
  LT,
  ...
}:
let
  # Package from NUR, with the local patches kept on top. The fork pins go.mod
  # to go 1.27.2 while nixpkgs builds with go 1.27.1 and GOTOOLCHAIN=local, so
  # relax the directive to the available major.minor (does not affect vendor).
  picoclaw = pkgs.nur-xddxdd.picoclaw.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../patches/picoclaw-disable-command-restrictions.patch
      ../../patches/picoclaw-mcp-json.patch
    ];
    postPatch = (old.postPatch or "") + ''
      sed -i -E "s/^go .*/go 1.27/" go.mod
    '';
  });
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
