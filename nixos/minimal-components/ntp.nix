{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  ntpServers = [ ];
  ntpPools = [
    "nixos.pool.ntp.org"
    "time.apple.com"
    "time.cloudflare.com"
    "time.google.com"
    "time.windows.com"
  ];
in
{
  networking.timeServers = ntpServers;

  services.timesyncd.enable = LT.this.hasTag LT.tags.low-ram;
  services.chrony = rec {
    enable = !(LT.this.hasTag LT.tags.low-ram);
    servers = [ ];
    # Use my custom makestep setting
    initstepslew.enabled = false;
    # https://github.com/mlichvar/chrony/blob/master/examples/chrony.conf.example3
    extraConfig = ''
      ${lib.concatMapStringsSep "\n" (k: "server ${k} ${serverOption}") ntpServers}
      ${lib.concatMapStringsSep "\n" (k: "pool ${k} ${serverOption}") ntpPools}

      cmdport 0
      makestep 1.0 3
      hwtimestamp *
    '';
    serverOption = if config.networking.networkmanager.enable then "offline" else "iburst";
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
