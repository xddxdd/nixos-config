{ pkgs, lib, dns, ... }:

with dns;
{
  Public = [
    (NAMESERVER { name = "linkin.lantian.pub."; })
    (NAMESERVER { name = "hostdare.lantian.pub."; })
    (NAMESERVER { name = "virmach-ny1g.lantian.pub."; })
    (NAMESERVER { name = "soyoustart.lantian.pub."; })
    (NAMESERVER { name = "buyvm.lantian.pub."; })
  ];

  LTNet = [
    (NAMESERVER { name = "linkin.zt.lantian.pub."; })
    (NAMESERVER { name = "hostdare.zt.lantian.pub."; })
    (NAMESERVER { name = "virmach-ny1g.zt.lantian.pub."; })
    (NAMESERVER { name = "soyoustart.zt.lantian.pub."; })
    (NAMESERVER { name = "buyvm.zt.lantian.pub."; })
  ];

  DN42 = [
    (NAMESERVER { name = "ns1.lantian.dn42."; })
    (NAMESERVER { name = "ns2.lantian.dn42."; })
    (NAMESERVER { name = "ns3.lantian.dn42."; })
    (NAMESERVER { name = "ns4.lantian.dn42."; })
    (NAMESERVER { name = "ns5.lantian.dn42."; })
    (NAMESERVER { name = "ns-anycast.lantian.dn42."; })
  ];

  NeoNetwork = [
    (NAMESERVER { name = "ns1.lantian.neo."; })
    (NAMESERVER { name = "ns2.lantian.neo."; })
    (NAMESERVER { name = "ns3.lantian.neo."; })
    (NAMESERVER { name = "ns4.lantian.neo."; })
    (NAMESERVER { name = "ns5.lantian.neo."; })
    (NAMESERVER { name = "ns-anycast.lantian.neo."; })
  ];
}
