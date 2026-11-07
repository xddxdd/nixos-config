{
  lib,
  LT,
  config,
  ...
}:
{
  options.lantian.firewall.presets.sidestore.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Rewrite SideStore's direct connection address (10.7.0.1) back to the client.";
  };

  config = lib.mkIf config.lantian.firewall.presets.sidestore.enable {
    lantian.firewall.chains.NAT_PREROUTING.rules = [
      {
        priority = LT.firewallPriorities.preService;
        text = "ip daddr 10.7.0.1 ip daddr set ip saddr ip saddr set 10.7.0.1 notrack";
      }
    ];
  };
}
