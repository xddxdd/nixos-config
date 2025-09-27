_:
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
