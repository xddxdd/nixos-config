{ lib, ... }:
{
  interfacePrefixes = {
    WAN = [
      "en"
      "eth"
      "henet"
      "usb"
      "venet"
      "wan"
      "wl"
      # "wlan" # covered by wl
    ];
    OVERLAY = [
      "ygg"
    ];
    DN42 = [
      "dn42"
      "neo"
    ];
    LAN = [
      "lan"
      "ns"
      "vboxnet"
      "virbr"
      "wgmesh"
    ];
  };
}
