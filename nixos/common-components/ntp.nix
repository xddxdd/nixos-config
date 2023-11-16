{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  ntpServers = [];
  ntpPools = [
    "nixos.pool.ntp.org"
    "time.apple.com"
    "time.cloudflare.com"
    "time.google.com"
    "time.windows.com"
  ];
in {
  networking.timeServers = ntpServers;

  services.timesyncd.enable = builtins.elem LT.tags.low-ram LT.this.tags;
  services.chrony = rec {
    enable = !(builtins.elem LT.tags.low-ram LT.this.tags);
    servers = [];
    extraConfig = ''
      ${lib.concatMapStringsSep "\n" (k: "server ${k} ${serverOption}") ntpServers}
      ${lib.concatMapStringsSep "\n" (k: "pool ${k} ${serverOption}") ntpPools}

      cmdport 0
    '';
    serverOption =
      if config.networking.networkmanager.enable
      then "offline"
      else "iburst";
  };

  systemd.services.chronyd.restartIfChanged = !config.networking.networkmanager.enable;

  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "chrony" ''
        INTERFACE=$1
        STATUS=$2

        # Make sure we're always getting the standard response strings
        LANG='C'

        CHRONY=${config.services.chrony.package}/bin/chronyc

        chrony_cmd() {
          echo "Chrony going $1."
          exec $CHRONY -a $1
        }

        nm_connected() {
          [ "$(${pkgs.networkmanager}/bin/nmcli -t --fields STATE g)" = 'connected' ]
        }

        case "$STATUS" in
          up)
            chrony_cmd online
          ;;
          vpn-up)
            chrony_cmd online
          ;;
          down)
            # Check for active interface, take offline if none is active
            nm_connected || chrony_cmd offline
          ;;
          vpn-down)
            # Check for active interface, take offline if none is active
            nm_connected || chrony_cmd offline
          ;;
        esac
      '';
    }
  ];
}
