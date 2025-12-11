_: {
  interfacePrefixes = {
    WAN = [
      "br"
      "en"
      "eth"
      "henet"
      "usb"
      "usque"
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
