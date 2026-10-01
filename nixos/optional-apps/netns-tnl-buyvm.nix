{
  lib,
  LT,
  config,
  ...
}:
{
  environment.etc."netns/tnl-buyvm/resolv.conf".text = ''
    nameserver 8.8.8.8
    options single-request edns
  '';

  lantian.netns.tnl-buyvm = {
    ipSuffix = "192";
    overrideRoutingTable = 10000 + LT.hosts.buyvm.index;
  };

  lantian.firewall.chains.FILTER_FORWARD.rules =
    lib.mkIf config.lantian.firewall.presets.interface-sets.enable
      [
        {
          priority = LT.firewallPriorities.terminal;
          text = ''iifname "ns-tnl-*" oifname @INTERFACE_WAN drop'';
        }
      ];
}
