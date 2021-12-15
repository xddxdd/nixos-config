{ pkgs, dns, ... }:

with dns;
let
  hosts = import ../hosts.nix;
  replacedHosts = {
    gigsgigscloud = hosts."50kvm";
    oneprovider = hosts."soyoustart";
    virmach-ny3ip = hosts."virmach-ny6g";
    virtono = hosts."buyvm";
  };

  forEachActiveHost = mapFunc: (pkgs.lib.mapAttrsToList mapFunc hosts);
  forEachHost = mapFunc: (pkgs.lib.mapAttrsToList mapFunc (hosts // replacedHosts));

  ptrPrefix = v: if (builtins.hasAttr "ptrPrefix" v) then "${v.ptrPrefix}." else "";

  mapAddresses = { name, addresses, enableWildcard ? false, ttl ? "1d" }:
    # A record
    pkgs.lib.optionals (builtins.hasAttr "IPv4" addresses) [
      (A { name = "${name}"; address = addresses.IPv4; inherit ttl; })
      (A { name = "v4.${name}"; address = addresses.IPv4; inherit ttl; })
    ]
    # AAAA record
    ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" addresses) [
      (AAAA { name = "${name}"; address = addresses.IPv6; inherit ttl; })
      (AAAA { name = "v6.${name}"; address = addresses.IPv6; inherit ttl; })
    ]
    ++ pkgs.lib.optionals (builtins.hasAttr "IPv6Alt" addresses) [
      (AAAA { name = "${name}"; address = addresses.IPv6Alt; inherit ttl; })
      (AAAA { name = "v6.${name}"; address = addresses.IPv6Alt; inherit ttl; })
    ]
    ++ pkgs.lib.optionals enableWildcard [
      (CNAME { name = "*.${name}"; target = name; inherit ttl; })
    ];
in
{
  mapAddresses = mapAddresses;

  CAA = [
    (CAA { name = "@"; tag = "issue"; value = "letsencrypt.org"; })
    (CAA { name = "@"; tag = "issuewild"; value = "letsencrypt.org"; })
  ];

  Normal = domain: enableWildcard: forEachHost
    (n: v: mapAddresses { name = "${n}.${domain}."; addresses = v.public; inherit enableWildcard; })
  ;

  SSHFP = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (pkgs.lib.hasAttrByPath [ "ssh" "rsa" ] v) [
      (SSHFP_RSA_SHA1 { name = "${n}.${domain}."; pubkey = v.ssh.rsa; })
      (SSHFP_RSA_SHA256 { name = "${n}.${domain}."; pubkey = v.ssh.rsa; })
    ]
    ++ pkgs.lib.optionals (pkgs.lib.hasAttrByPath [ "ssh" "ed25519" ] v) [
      (SSHFP_ED25519_SHA1 { name = "${n}.${domain}."; pubkey = v.ssh.ed25519; })
      (SSHFP_ED25519_SHA256 { name = "${n}.${domain}."; pubkey = v.ssh.ed25519; })
    ])
  ;

  TXT = domain: forEachActiveHost
    (n: v: [
      (TXT { name = "hosts.${domain}."; contents = "${n}.${domain}"; })
    ])
  ;

  LTNet = domain: enableWildcard: forEachHost
    (n: v: mapAddresses { name = "${n}.${domain}."; addresses = v.ltnet; inherit enableWildcard; })
  ;

  LTNetReverseIPv4 = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv4Prefix" v.ltnet) [
      (PTR { name = v.ltnet.IPv4; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
  ;

  LTNetReverseIPv6 = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv6Prefix" v.ltnet) [
      (PTR { name = v.ltnet.IPv6; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
  ;

  DN42 = domain: enableWildcard: forEachHost
    (n: v: (
      (mapAddresses { name = "${n}.${domain}."; addresses = v.dn42; inherit enableWildcard; })
      # A record
      ++ pkgs.lib.optionals (builtins.hasAttr "IPv4" v.dn42) [
        (A { name = "dns-authoritative.${n}.${domain}."; address = v.dn42.IPv4; })
      ]
      # AAAA record
      ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" v.dn42) [
        (AAAA { name = "dns-recursive.${n}.${domain}."; address = "${v.ltnet.IPv6Prefix}::53"; })
        (AAAA { name = "dns-authoritative.${n}.${domain}."; address = "${v.ltnet.IPv6Prefix}::54"; })
        (AAAA { name = "dns-authoritative-backend.${n}.${domain}."; address = "${v.ltnet.IPv6Prefix}::55"; })
      ]
    ))
  ;

  # Special handling: split for IP ranges & keep only last part of IP
  DN42ReverseIPv4 =
    let
      lastPart = ip: builtins.elemAt (pkgs.lib.splitString "." ip) 3;
    in
    domain: ipMin: ipMax: forEachActiveHost
      (n: v:
        let
          i = pkgs.lib.toInt (lastPart v.dn42.IPv4);
          inRange = i >= ipMin && i <= ipMax;
        in
        pkgs.lib.optionals (inRange && builtins.hasAttr "IPv4" v.dn42) [
          (PTR { name = lastPart v.dn42.IPv4; target = "${ptrPrefix v}${n}.${domain}."; })
        ]);

  DN42ReverseIPv6 = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv6" v.dn42) [
      (PTR { name = v.dn42.IPv6; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
  ;

  NeoNetwork = domain: enableWildcard: forEachHost
    (n: v: mapAddresses { name = "${n}.${domain}."; addresses = v.neonetwork; inherit enableWildcard; })
  ;

  NeoNetworkReverseIPv4 = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv4" v.neonetwork) [
      (PTR { name = v.neonetwork.IPv4; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
  ;

  NeoNetworkReverseIPv6 = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (builtins.hasAttr "IPv6" v.neonetwork) [
      (PTR { name = v.neonetwork.IPv6; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
  ;
}
