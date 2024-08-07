{ pkgs, LT, ... }:
let
  cfg = pkgs.writeText "endlessh.conf" ''
    # The port on which to listen for new SSH connections.
    Port 22

    # The endless banner is sent one line at a time. This is the delay
    # in milliseconds between individual lines.
    Delay 10000

    # The length of each line is randomized. This controls the maximum
    # length of each line. Shorter lines may keep clients on for longer if
    # they give up after a certain number of bytes.
    MaxLineLength 32

    # Maximum number of connections to accept at a time. Connections beyond
    # this are not immediately rejected, but will wait in the queue.
    MaxClients 4096

    # Set the detail level for the log.
    #   0 = Quiet
    #   1 = Standard, useful log messages
    #   2 = Very noisy debugging information
    LogLevel 0

    # Set the family of the listening socket
    #   0 = Use IPv4 Mapped IPv6 (Both v4 and v6, default)
    #   4 = Use IPv4 only
    #   6 = Use IPv6 only
    BindFamily 0
  '';
in
{
  services.endlessh = {
    enable = LT.this.hasTag LT.tags.low-ram;
    port = 22;
    extraOptions = [
      "-f"
      "${cfg}"
    ];
  };

  services.endlessh-go = {
    enable = !(LT.this.hasTag LT.tags.low-ram);
    port = 22;
    prometheus = {
      enable = true;
      port = LT.port.Prometheus.EndlesshGo;
      listenAddress = LT.this.ltnet.IPv4;
    };
    extraOptions = [
      "-geoip_supplier=max-mind-db"
      "-max_mind_db=/nix/persistent/sync-servers/geoip/GeoLite2-City.mmdb"
    ];
  };

  systemd.services.endlessh-go = {
    after = [ "network.target" ];
    serviceConfig.BindReadOnlyPaths = [ "/nix/persistent/sync-servers/geoip" ];
  };
}
