{
  pkgs,
  lib,
  dns,
  ...
}:
with dns; {
  Public = [
    (NAMESERVER {name = "v-ps-hkg.lantian.pub.";})
    (NAMESERVER {name = "v-ps-sjc.lantian.pub.";})
    (NAMESERVER {name = "virmach-ny1g.lantian.pub.";})
    (NAMESERVER {name = "hetzner-de.lantian.pub.";})
    (NAMESERVER {name = "buyvm.lantian.pub.";})
  ];

  LTNet = [
    (NAMESERVER {name = "v-ps-hkg.ltnet.lantian.pub.";})
    (NAMESERVER {name = "v-ps-sjc.ltnet.lantian.pub.";})
    (NAMESERVER {name = "virmach-ny1g.ltnet.lantian.pub.";})
    (NAMESERVER {name = "hetzner-de.ltnet.lantian.pub.";})
    (NAMESERVER {name = "buyvm.ltnet.lantian.pub.";})
  ];

  DN42 = [
    (NAMESERVER {name = "ns1.lantian.dn42.";})
    (NAMESERVER {name = "ns2.lantian.dn42.";})
    (NAMESERVER {name = "ns3.lantian.dn42.";})
    (NAMESERVER {name = "ns4.lantian.dn42.";})
    (NAMESERVER {name = "ns5.lantian.dn42.";})
    (NAMESERVER {name = "ns-anycast.lantian.dn42.";})
  ];

  NeoNetwork = [
    (NAMESERVER {name = "ns1.lantian.neo.";})
    (NAMESERVER {name = "ns2.lantian.neo.";})
    (NAMESERVER {name = "ns3.lantian.neo.";})
    (NAMESERVER {name = "ns4.lantian.neo.";})
    (NAMESERVER {name = "ns5.lantian.neo.";})
    (NAMESERVER {name = "ns-anycast.lantian.neo.";})
  ];
}
