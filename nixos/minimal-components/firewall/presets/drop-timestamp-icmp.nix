{
  lib,
  LT,
  config,
  ...
}:
{
  options.lantian.firewall.presets.drop-timestamp-icmp.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Drop ICMP timestamp request/reply packets.";
  };

  config = lib.mkIf config.lantian.firewall.presets.drop-timestamp-icmp.enable {
    lantian.firewall.chains.FILTER_INPUT.rules = [
      {
        priority = LT.firewallPriorities.early;
        text = ''
          meta l4proto icmp icmp type timestamp-reply drop
          meta l4proto icmp icmp type timestamp-request drop
        '';
      }
    ];
  };
}
