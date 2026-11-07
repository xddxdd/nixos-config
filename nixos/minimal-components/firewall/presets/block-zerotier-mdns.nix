{
  lib,
  LT,
  config,
  ...
}:
{
  options.lantian.firewall.presets.block-zerotier-mdns.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Block mDNS (port 5353) on ZeroTier interfaces.";
  };

  config = lib.mkIf config.lantian.firewall.presets.block-zerotier-mdns.enable {
    lantian.firewall.chains.FILTER_INPUT.rules = [
      {
        priority = LT.firewallPriorities.preService;
        text = ''
          iifname "zt*" udp sport 5353 reject
          iifname "zt*" udp dport 5353 reject
        '';
      }
    ];
    lantian.firewall.chains.FILTER_OUTPUT.rules = [
      {
        priority = LT.firewallPriorities.early;
        text = ''
          oifname "zt*" udp sport 5353 reject
          oifname "zt*" udp dport 5353 reject
        '';
      }
    ];
  };
}
