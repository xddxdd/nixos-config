{
  lib,
  LT,
  config,
  ...
}:
{
  options.lantian.firewall.presets.masquerade.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Masquerade traffic leaving the reserved (LAN) address space.";
  };

  config = lib.mkIf config.lantian.firewall.presets.masquerade.enable {
    lantian.firewall.chains.NAT_POSTROUTING.rules = [
      {
        priority = LT.firewallPriorities.terminal;
        text = ''
          ip saddr @RESERVED_IPV4 ip daddr != @RESERVED_IPV4 masquerade
          ip6 saddr @RESERVED_IPV6 ip6 daddr != @RESERVED_IPV6 masquerade
        '';
      }
    ];
  };
}
