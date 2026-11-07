{
  config,
  LT,
  ...
}:
let
  port = LT.port.FirewallCanary;
in
{
  # Deliberate port 1 listener, exposed to LAN only: reachable from WAN only
  # when a firewall fails to block it.
  services.nginx.virtualHosts."lantian-firewall-canary" = {
    serverName = "_";
    listen = [
      {
        addr = "0.0.0.0";
        inherit port;
      }
      {
        addr = "[::]";
        inherit port;
      }
    ];
    locations."/" = {
      return = "444";
      extraConfig = "access_log off;";
    };
  };
  lantian.firewall.zones.LAN.tcpPorts."${LT.portStr.FirewallCanary}" = {
    type = "local";
  };

  assertions = [
    {
      assertion = !(builtins.hasAttr (toString port) config.lantian.firewall.zones.WAN.tcpPorts);
      message = "TCP port ${toString port} is the firewall canary and must stay closed on WAN, but lantian.firewall.zones.WAN.tcpPorts opens it";
    }
  ];
}
