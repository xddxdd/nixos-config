{
  lib,
  LT,
  config,
  ...
}:
let
  cfg = config.lantian.firewall.presets.masquerade-outbound;
in
{
  options.lantian.firewall.presets.masquerade-outbound = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Masquerade all IPv4 traffic leaving via any interface except the excluded ones.";
    };
    excludeInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Interface match expressions excluded from masquerading.";
    };
  };

  config = lib.mkIf cfg.enable {
    lantian.firewall.chains.NAT_POSTROUTING.rules = [
      {
        priority = LT.firewallPriorities.early;
        text = "meta nfproto ipv4 ${
          lib.concatMapStrings (i: "oifname != ${i} ") cfg.excludeInterfaces
        }masquerade";
      }
    ];
  };
}
