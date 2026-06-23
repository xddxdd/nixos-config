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
    "ns-anycast.lantian.dn42."
  ];

  NeoNetworkServers = [
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

  common.soa = {
    DN42 = {
      recordType = "SOA";
      name = "@";
      nameserver = "ns-anycast.lantian.dn42.";
      email = "lantian.lantian.dn42.";
      refresh = 360;
      retry = 600;
      expire = 604800;
      minimum = 600;
    };
    NeoNetwork = {
      recordType = "SOA";
      name = "@";
      nameserver = "ns-anycast.lantian.neo.";
      email = "lantian.lantian.neo.";
      refresh = 360;
      retry = 600;
      expire = 604800;
      minimum = 600;
    };
  };
}
