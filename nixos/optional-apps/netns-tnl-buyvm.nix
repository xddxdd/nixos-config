{
  LT,
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

  # The tunnel namespace routes through its own tunnel; it must not forward
  # to WAN or DN42 through the host.
  lantian.firewall.zones = {
    NETNS_TNL_BUYVM.forwardTo = [ "LTNET" ];
  };
}
