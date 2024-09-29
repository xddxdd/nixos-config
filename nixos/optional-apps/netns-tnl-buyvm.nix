{
  LT,
  ...
}:
{
  environment.etc."netns/tnl-buyvm/resolv.conf".text = ''
    nameserver 8.8.8.8
    options single-request edns0
  '';

  lantian.netns.tnl-buyvm = {
    ipSuffix = "192";
    overrideRoutingTable = 10000 + LT.hosts.buyvm.index;
  };
}
