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

  ptrPrefix = v: if (builtins.hasAttr "ptrPrefix" v) then "${v.ptrPrefix}." else "";
in
{
  CAA = [
    (CAA { name = "@"; tag = "issue"; value = "globalsign.com"; })
    (CAA { name = "@"; tag = "issue"; value = "digicert.com"; })
    (CAA { name = "@"; tag = "issue"; value = "comodoca.com"; })
    (CAA { name = "@"; tag = "issue"; value = "buypass.com"; })
    (CAA { name = "@"; tag = "issue"; value = "symantec.com"; })
    (CAA { name = "@"; tag = "issue"; value = "letsencrypt.org"; })
    (CAA { name = "@"; tag = "issuewild"; value = "letsencrypt.org"; })
  ];

  Normal = domain: pkgs.lib.flatten
    ((pkgs.lib.mapAttrsToList
      (n: v: (
        # A record
        pkgs.lib.optionals (builtins.hasAttr "IPv4" v.public) [
          (A { name = n; address = v.public.IPv4; })
          (A { name = "v4.${n}"; address = v.public.IPv4; })
        ]
        # AAAA record
        ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" v.public) [
          (AAAA { name = n; address = v.public.IPv6; })
          (AAAA { name = "v6.${n}"; address = v.public.IPv6; })
        ]
        ++ pkgs.lib.optionals (builtins.hasAttr "IPv6Alt" v.public) [
          (AAAA { name = n; address = v.public.IPv6Alt; })
          (AAAA { name = "v6.${n}"; address = v.public.IPv6Alt; })
        ]
      ))
      hosts) ++ (pkgs.lib.mapAttrsToList
      (name: target: [
        (CNAME { inherit name target; })
        (CNAME { name = "v4.${name}"; target = "v4.${target}.${domain}."; })
        (CNAME { name = "v6.${name}"; target = "v6.${target}.${domain}."; })
      ])
      replacedHosts));

  SSHFP = domain: pkgs.lib.flatten
    (pkgs.lib.mapAttrsToList
      (n: v: pkgs.lib.optionals (builtins.hasAttr "sshPubRSA" v) [
        (SSHFP_RSA_SHA1 { name = n; pubkey = v.sshPubRSA; })
        (SSHFP_RSA_SHA256 { name = n; pubkey = v.sshPubRSA; })
      ]
      ++ pkgs.lib.optionals (builtins.hasAttr "sshPubEd25519" v) [
        (SSHFP_ED25519_SHA1 { name = n; pubkey = v.sshPubEd25519; })
        (SSHFP_ED25519_SHA256 { name = n; pubkey = v.sshPubEd25519; })
      ])
      hosts);

  Wildcard = domain: pkgs.lib.flatten
    ((pkgs.lib.mapAttrsToList
      (n: v: [
        (CNAME { name = "*.${n}"; target = n; })
      ])
      hosts) ++ (pkgs.lib.mapAttrsToList
      (name: target: [
        (CNAME { name = "*.${name}"; inherit target; })
      ])
      replacedHosts)
    );

  TXT = domain: pkgs.lib.flatten (pkgs.lib.mapAttrsToList
    (n: v: [
      (TXT { name = "hosts"; contents = "${n}.${domain}"; })
    ])
    hosts);

  LTNet = domain: pkgs.lib.flatten
    ((pkgs.lib.mapAttrsToList
      (n: v: (
        # A record
        pkgs.lib.optionals (builtins.hasAttr "IPv4Prefix" v.ltnet) [
          (A { name = n; address = "${v.ltnet.IPv4Prefix}.1"; })
          (A { name = "v4.${n}"; address = "${v.ltnet.IPv4Prefix}.1"; })
        ]
        # AAAA record
        ++ pkgs.lib.optionals (builtins.hasAttr "IPv6Prefix" v.ltnet) [
          (AAAA { name = n; address = "${v.ltnet.IPv6Prefix}::1"; })
          (AAAA { name = "v6.${n}"; address = "${v.ltnet.IPv6Prefix}::1"; })
        ]
        ++ [
          (CNAME { name = "*.${n}"; target = n; })
        ]
      ))
      hosts) ++ (pkgs.lib.mapAttrsToList
      (name: target: [
        (CNAME { inherit name target; })
        (CNAME { name = "*.${name}"; inherit target; })
        (CNAME { name = "v4.${name}"; target = "v4.${target}.${domain}."; })
        (CNAME { name = "v6.${name}"; target = "v6.${target}.${domain}."; })
      ])
      replacedHosts));

  LTNetReverseIPv4 = domain: pkgs.lib.flatten
    (pkgs.lib.mapAttrsToList
      (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv4Prefix" v.ltnet) [
        (PTR { name = "${v.ltnet.IPv4Prefix}.1"; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
      ])
      hosts);

  LTNetReverseIPv6 = domain: pkgs.lib.flatten
    (pkgs.lib.mapAttrsToList
      (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv6Prefix" v.ltnet) [
        (PTR { name = "${v.ltnet.IPv6Prefix}::1"; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
      ])
      hosts);

  DN42 = domain: pkgs.lib.flatten
    ((pkgs.lib.mapAttrsToList
      (n: v: (
        # A record
        pkgs.lib.optionals (builtins.hasAttr "IPv4" v.dn42) [
          (A { name = n; address = v.dn42.IPv4; })
          (A { name = "v4.${n}"; address = v.dn42.IPv4; })
          (A { name = "dns-authoritative.${n}"; address = v.dn42.IPv4; })
        ]
        # AAAA record
        ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" v.dn42) [
          (AAAA { name = n; address = v.dn42.IPv6; })
          (AAAA { name = "v6.${n}"; address = v.dn42.IPv6; })
          (AAAA { name = "dns-recursive.${n}"; address = "${v.ltnet.IPv6Prefix}::53"; })
          (AAAA { name = "dns-authoritative.${n}"; address = "${v.ltnet.IPv6Prefix}::54"; })
          (AAAA { name = "dns-authoritative-backend.${n}"; address = "${v.ltnet.IPv6Prefix}::55"; })
        ]
      ))
      hosts) ++ (pkgs.lib.mapAttrsToList
      (name: target: [
        (CNAME { inherit name target; })
        (CNAME { name = "dns-recursive.${name}"; target = "dns-recursive.${target}.${domain}."; })
        (CNAME { name = "dns-authoritative.${name}"; target = "dns-authoritative.${target}.${domain}."; })
        (CNAME { name = "dns-authoritative-backend.${name}"; target = "dns-authoritative-backend.${target}.${domain}."; })
        (CNAME { name = "v4.${name}"; target = "v4.${target}.${domain}."; })
        (CNAME { name = "v6.${name}"; target = "v6.${target}.${domain}."; })
      ])
      replacedHosts));

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

  DN42ReverseIPv6 = domain: pkgs.lib.flatten
    (pkgs.lib.mapAttrsToList
      (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv6" v.dn42) [
        (PTR { name = v.dn42.IPv6; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
      ])
      hosts);

  NeoNetwork = domain: pkgs.lib.flatten
    ((pkgs.lib.mapAttrsToList
      (n: v: (
        # A record
        pkgs.lib.optionals (builtins.hasAttr "IPv4" v.neonetwork) [
          (A { name = n; address = v.neonetwork.IPv4; })
          (A { name = "v4.${n}"; address = v.neonetwork.IPv4; })
        ]
        # AAAA record
        ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" v.neonetwork) [
          (AAAA { name = n; address = v.neonetwork.IPv6; })
          (AAAA { name = "v6.${n}"; address = v.neonetwork.IPv6; })
        ]
      ))
      hosts) ++ (pkgs.lib.mapAttrsToList
      (name: target: [
        (CNAME { inherit name target; })
        (CNAME { name = "v4.${name}"; target = "v4.${target}.${domain}."; })
        (CNAME { name = "v6.${name}"; target = "v6.${target}.${domain}."; })
      ])
      replacedHosts));

  NeoNetworkReverseIPv4 = domain: pkgs.lib.flatten
    (pkgs.lib.mapAttrsToList
      (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv4" v.neonetwork) [
        (PTR { name = v.neonetwork.IPv4; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
      ])
      hosts);

  NeoNetworkReverseIPv6 = domain: pkgs.lib.flatten
    (pkgs.lib.mapAttrsToList
      (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv6" v.neonetwork) [
        (PTR { name = v.neonetwork.IPv6; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
      ])
      hosts);
}
