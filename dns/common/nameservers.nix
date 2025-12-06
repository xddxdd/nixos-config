_:
let
  PublicServers = [
    "zgocloud.lantian.pub."
    "bwg-lax.lantian.pub."
    "virmach-ny1g.lantian.pub."
    "colocrossing.lantian.pub."
    "buyvm.lantian.pub."
  ];

  LTNetServers = [
    "zgocloud.ltnet.lantian.pub."
    "bwg-lax.ltnet.lantian.pub."
    "virmach-ny1g.ltnet.lantian.pub."
    "colocrossing.ltnet.lantian.pub."
    "buyvm.ltnet.lantian.pub."
  ];

  DN42Servers = [
    "ns1.lantian.dn42."
    "ns2.lantian.dn42."
    "ns3.lantian.dn42."
    "ns4.lantian.dn42."
    "ns5.lantian.dn42."
    "ns-anycast.lantian.dn42."
  ];

  NeoNetworkServers = [
    "ns1.lantian.neo."
    "ns2.lantian.neo."
    "ns3.lantian.neo."
    "ns4.lantian.neo."
    "ns5.lantian.neo."
    "ns-anycast.lantian.neo."
  ];

  mapNameservers = builtins.map (n: {
    recordType = "NAMESERVER";
    name = n;
  });
  mapNSRecords =
    servers: name:
    builtins.map (n: {
      recordType = "NS";
      inherit name;
      target = n;
    }) servers;
in
{
  common.nameservers = {
    Public = mapNameservers PublicServers;
    PublicNSRecords = mapNSRecords PublicServers;

    LTNet = mapNameservers LTNetServers;
    LTNetNSRecords = mapNSRecords LTNetServers;

    DN42 = mapNameservers DN42Servers;
    DN42NSRecords = mapNSRecords DN42Servers;

    NeoNetwork = mapNameservers NeoNetworkServers;
    NeoNetworkRecords = mapNSRecords NeoNetworkServers;
  };
}
