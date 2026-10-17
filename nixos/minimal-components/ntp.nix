{ LT, ... }:
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

  systemd.services.ntpd-rs.serviceConfig = LT.serviceHarden // {
    # ntpd-rs sets the system clock; ProtectClock and the ~@cache syscall
    # block in serviceHarden would block its adjtimex calls
    ProtectClock = false;
    SystemCallFilter = [ ];
  };

  services.ntpd-rs = {
    enable = true;
    useNetworkingTimeServers = false;
    settings = {
      observability.log-level = "error";
      source =
        (builtins.map (n: {
          mode = "server";
          address = n;
        }) ntpServers)
        ++ (builtins.map (n: {
          mode = "pool";
          address = n;
        }) ntpPools);
    };
  };
}
