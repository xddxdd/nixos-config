{
  lib,
  LT,
  config,
  ...
}:
let
  cfg = config.lantian.firewall.presets.block-ipv6;
in
{
  options.lantian.firewall.presets.block-ipv6 = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Drop all IPv6 traffic on the given interfaces.";
    };
    interfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Interface match expressions.";
    };
  };

  config = lib.mkIf cfg.enable {
    lantian.firewall.chains.FILTER_INPUT.rules = [
      {
        priority = LT.firewallPriorities.preService;
        text = lib.concatStringsSep "\n" (map (i: "iifname ${i} meta nfproto ipv6 drop") cfg.interfaces);
      }
    ];
    lantian.firewall.chains.FILTER_OUTPUT.rules = [
      {
        priority = LT.firewallPriorities.preService;
        text = lib.concatStringsSep "\n" (map (i: "oifname ${i} meta nfproto ipv6 drop") cfg.interfaces);
      }
    ];
  };
}
