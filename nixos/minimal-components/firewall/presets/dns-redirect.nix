{
  lib,
  LT,
  config,
  ...
}:
let
  cfg = config.lantian.firewall.presets.dns-redirect;
  iifnames = lib.concatMapStrings (j: " iifname ${j}") cfg.lanInterfaces;
in
{
  options.lantian.firewall.presets.dns-redirect = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Hijack locally-destined DNS (port 53) into a network namespace running CoreDNS.";
    };
    netns = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Network namespace (under lantian.netns) receiving the DNS traffic.";
    };
    lanInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Interface match expressions the redirect applies to; empty means all interfaces.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.netns != null) {
    lantian.firewall.chains.NAT_PREROUTING.dnat = [
      {
        priority = LT.firewallPriorities.service;
        matches = map (proto: "fib daddr type local ${proto} dport ${LT.portStr.DNS}${iifnames}") [
          "tcp"
          "udp"
        ];
        ipv4 = "${config.lantian.netns.${cfg.netns}.ipv4}:${LT.portStr.DNS}";
        ipv6 = "[${config.lantian.netns.${cfg.netns}.ipv6}]:${LT.portStr.DNS}";
      }
    ];
  };
}
