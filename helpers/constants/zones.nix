{ lib, ... }:
{
  zones = {
    DN42 = [
      "dn42"
      "10.in-addr.arpa"
      "20.172.in-addr.arpa"
      "21.172.in-addr.arpa"
      "22.172.in-addr.arpa"
      "23.172.in-addr.arpa"
      "31.172.in-addr.arpa"
      "d.f.ip6.arpa"
    ];
    NeoNetwork = [ "neo" ];
    # .neo zone not included for conflict with NeoNetwork
    OpenNIC = [
      "bbs"
      "chan"
      "cyb"
      "dns.opennic.glue"
      "dyn"
      "epic"
      "fur"
      "geek"
      "gopher"
      "indy"
      "libre"
      "null"
      "o"
      "opennic.glue"
      "oss"
      "oz"
      "parody"
      "pirate"
    ];
    Emercoin = [
      "bazar"
      "coin"
      "emc"
      "lib"
    ];
    YggdrasilAlfis = [
      "anon"
      "btn"
      "conf"
      "index"
      "merch"
      "mirror"
      "mob"
      "screen"
      "srv"
      "ygg"
    ];
    CRXN = [ "crxn" ];
    Meshname = [
      "meshname"
      "meship"
    ];
    Ltnet = [
      "0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa"
      "10.127.10.in-addr.arpa"
      "18.198.in-addr.arpa"
      "19.198.in-addr.arpa"
      "d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa"
      "lantian.dn42"
      "lantian.neo"
      # Lan Tian Mobile VoLTE
      "mnc001.mcc001.3gppnetwork.org"
      "mnc010.mcc315.3gppnetwork.org"
      "mnc999.mcc999.3gppnetwork.org"
    ];
    Others = [
      "database.azure.com"
    ];
  };
}
