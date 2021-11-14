{ pkgs, dns, ... }:

with dns;
let
  hosts = import ../hosts.nix;
  replacedHosts = {
    gigsgigscloud = "50kvm";
    oneprovider = "soyoustart";
    virmach-ny3ip = "virmach-ny6g";
    virtono = "buyvm";
  };

  forEachHost = mapFunc: replacedMapFunc: pkgs.lib.flatten
    ((pkgs.lib.mapAttrsToList mapFunc hosts) ++ (pkgs.lib.mapAttrsToList replacedMapFunc replacedHosts));
  hostNoopFunc = name: target: [ ];

  ptrPrefix = v: if (builtins.hasAttr "ptrPrefix" v) then "${v.ptrPrefix}." else "";
in
{
  CAA = [
    (CAA { name = "@"; tag = "issue"; value = "letsencrypt.org"; })
    (CAA { name = "@"; tag = "issuewild"; value = "letsencrypt.org"; })
  ];

  Normal = domain: forEachHost
    (n: v: (
      # A record
      pkgs.lib.optionals (builtins.hasAttr "IPv4" v.public) [
        (A { name = "${n}.${domain}."; address = v.public.IPv4; })
        (A { name = "v4.${n}.${domain}."; address = v.public.IPv4; })
      ]
      # AAAA record
      ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" v.public) [
        (AAAA { name = "${n}.${domain}."; address = v.public.IPv6; })
        (AAAA { name = "v6.${n}.${domain}."; address = v.public.IPv6; })
      ]
      ++ pkgs.lib.optionals (builtins.hasAttr "IPv6Alt" v.public) [
        (AAAA { name = "${n}.${domain}."; address = v.public.IPv6Alt; })
        (AAAA { name = "v6.${n}.${domain}."; address = v.public.IPv6Alt; })
      ]
    ))
    (name: target: [
      (CNAME { name = "${name}.${domain}."; inherit target; })
      (CNAME { name = "v4.${name}.${domain}."; target = "v4.${target}.${domain}."; })
      (CNAME { name = "v6.${name}.${domain}."; target = "v6.${target}.${domain}."; })
    ])
  ;

  SSHFP = domain: forEachHost
    (n: v: pkgs.lib.optionals (builtins.hasAttr "sshPubRSA" v) [
      (SSHFP_RSA_SHA1 { name = "${n}.${domain}."; pubkey = v.sshPubRSA; })
      (SSHFP_RSA_SHA256 { name = "${n}.${domain}."; pubkey = v.sshPubRSA; })
    ]
    ++ pkgs.lib.optionals (builtins.hasAttr "sshPubEd25519" v) [
      (SSHFP_ED25519_SHA1 { name = "${n}.${domain}."; pubkey = v.sshPubEd25519; })
      (SSHFP_ED25519_SHA256 { name = "${n}.${domain}."; pubkey = v.sshPubEd25519; })
    ])
    hostNoopFunc
  ;

  Wildcard = domain: forEachHost
    (n: v: [
      (CNAME { name = "*.${n}.${domain}."; target = "${n}.${domain}."; })
    ])
    (name: target: [
      (CNAME { name = "*.${name}.${domain}."; inherit target; })
    ])
  ;

  TXT = domain: forEachHost
    (n: v: [
      (TXT { name = "hosts.${domain}."; contents = "${n}.${domain}"; })
    ])
    hostNoopFunc
  ;

  LTNet = domain: forEachHost
    (n: v: (
      # A record
      pkgs.lib.optionals (builtins.hasAttr "IPv4Prefix" v.ltnet) [
        (A { name = "${n}.${domain}."; address = v.ltnet.IPv4; })
        (A { name = "v4.${n}.${domain}."; address = v.ltnet.IPv4; })
      ]
      # AAAA record
      ++ pkgs.lib.optionals (builtins.hasAttr "IPv6Prefix" v.ltnet) [
        (AAAA { name = "${n}.${domain}."; address = v.ltnet.IPv6; })
        (AAAA { name = "v6.${n}.${domain}."; address = v.ltnet.IPv6; })
      ]
      ++ [
        (CNAME { name = "*.${n}.${domain}."; target = n; })
      ]
    ))
    (name: target: [
      (CNAME { name = "${name}.${domain}."; inherit target; })
      (CNAME { name = "*.${name}.${domain}."; inherit target; })
      (CNAME { name = "v4.${name}.${domain}."; target = "v4.${target}.${domain}."; })
      (CNAME { name = "v6.${name}.${domain}."; target = "v6.${target}.${domain}."; })
    ])
  ;

  LTNetReverseIPv4 = domain: forEachHost
    (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv4Prefix" v.ltnet) [
      (PTR { name = v.ltnet.IPv4; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
    hostNoopFunc
  ;

  LTNetReverseIPv6 = domain: forEachHost
    (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv6Prefix" v.ltnet) [
      (PTR { name = v.ltnet.IPv6; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
    hostNoopFunc
  ;

  DN42 = domain: forEachHost
    (n: v: (
      # A record
      pkgs.lib.optionals (builtins.hasAttr "IPv4" v.dn42) [
        (A { name = "${n}.${domain}."; address = v.dn42.IPv4; })
        (A { name = "v4.${n}.${domain}."; address = v.dn42.IPv4; })
        (A { name = "dns-authoritative.${n}.${domain}."; address = v.dn42.IPv4; })
      ]
      # AAAA record
      ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" v.dn42) [
        (AAAA { name = "${n}.${domain}."; address = v.dn42.IPv6; })
        (AAAA { name = "v6.${n}.${domain}."; address = v.dn42.IPv6; })
        (AAAA { name = "dns-recursive.${n}.${domain}."; address = "${v.ltnet.IPv6Prefix}::53"; })
        (AAAA { name = "dns-authoritative.${n}.${domain}."; address = "${v.ltnet.IPv6Prefix}::54"; })
        (AAAA { name = "dns-authoritative-backend.${n}.${domain}."; address = "${v.ltnet.IPv6Prefix}::55"; })
      ]
    ))
    (name: target: [
      (CNAME { name = "${name}.${domain}."; inherit target; })
      (CNAME { name = "dns-recursive.${name}.${domain}."; target = "dns-recursive.${target}.${domain}."; })
      (CNAME { name = "dns-authoritative.${name}.${domain}."; target = "dns-authoritative.${target}.${domain}."; })
      (CNAME { name = "dns-authoritative-backend.${name}.${domain}."; target = "dns-authoritative-backend.${target}.${domain}."; })
      (CNAME { name = "v4.${name}.${domain}."; target = "v4.${target}.${domain}."; })
      (CNAME { name = "v6.${name}.${domain}."; target = "v6.${target}.${domain}."; })
    ])
  ;

  # Special handling: split for IP ranges & keep only last part of IP
  DN42ReverseIPv4 =
    let
      lastPart = ip: builtins.elemAt (pkgs.lib.splitString "." ip) 3;
    in
    domain: ipMin: ipMax: pkgs.lib.flatten
      (pkgs.lib.mapAttrsToList
        (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv4" v.dn42) [
          (PTR { name = lastPart v.dn42.IPv4; target = "${ptrPrefix v}${n}.${domain}."; })
        ])
        (pkgs.lib.filterAttrs
          (n: v:
            let
              i = pkgs.lib.toInt (lastPart v.dn42.IPv4);
            in
            i >= ipMin && i <= ipMax)
          hosts));

  DN42ReverseIPv6 = domain: forEachHost
    (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv6" v.dn42) [
      (PTR { name = v.dn42.IPv6; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
    hostNoopFunc
  ;

  NeoNetwork = domain: forEachHost
    (n: v: (
      # A record
      pkgs.lib.optionals (builtins.hasAttr "IPv4" v.neonetwork) [
        (A { name = "${n}.${domain}."; address = v.neonetwork.IPv4; })
        (A { name = "v4.${n}.${domain}."; address = v.neonetwork.IPv4; })
      ]
      # AAAA record
      ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" v.neonetwork) [
        (AAAA { name = "${n}.${domain}."; address = v.neonetwork.IPv6; })
        (AAAA { name = "v6.${n}.${domain}."; address = v.neonetwork.IPv6; })
      ]
    ))
    (name: target: [
      (CNAME { name = "${name}.${domain}."; inherit target; })
      (CNAME { name = "v4.${name}.${domain}."; target = "v4.${target}.${domain}."; })
      (CNAME { name = "v6.${name}.${domain}."; target = "v6.${target}.${domain}."; })
    ])
  ;

  NeoNetworkReverseIPv4 = domain: forEachHost
    (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv4" v.neonetwork) [
      (PTR { name = v.neonetwork.IPv4; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
    hostNoopFunc
  ;

  NeoNetworkReverseIPv6 = domain: forEachHost
    (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv6" v.neonetwork) [
      (PTR { name = v.neonetwork.IPv6; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
    hostNoopFunc
  ;
}
