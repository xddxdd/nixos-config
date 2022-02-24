{ pkgs, dns, hosts, ... }:

with dns;
let
  roles = import ../../helpers/roles.nix;

  replacedHosts = {
    gigsgigscloud = hosts."50kvm";
    oneprovider = hosts."soyoustart";
    virmach-ny3ip = hosts."virmach-ny6g";
    virtono = hosts."buyvm";
  };

  forEachActiveHost = mapFunc: (pkgs.lib.mapAttrsToList mapFunc hosts);
  forEachHost = mapFunc: (pkgs.lib.mapAttrsToList mapFunc (hosts // replacedHosts));

  ptrPrefix = v: if (v.ptrPrefix != "") then "${v.ptrPrefix}." else "";

  mapAddresses = { name, addresses, ttl ? "1d" }:
    # A record
    pkgs.lib.optionals (addresses.IPv4 != "") [
      (A { name = "${name}"; address = addresses.IPv4; inherit ttl; })
      (A { name = "v4.${name}"; address = addresses.IPv4; inherit ttl; })
    ]
    # AAAA record
    ++ pkgs.lib.optionals (addresses.IPv6 != "") [
      (AAAA { name = "${name}"; address = addresses.IPv6; inherit ttl; })
      (AAAA { name = "v6.${name}"; address = addresses.IPv6; inherit ttl; })
    ]
    ++ pkgs.lib.optionals (addresses.IPv6Alt or "" != "") [
      (AAAA { name = "${name}"; address = addresses.IPv6Alt; inherit ttl; })
      (AAAA { name = "v6.${name}"; address = addresses.IPv6Alt; inherit ttl; })
    ];
in
{
  mapAddresses = mapAddresses;

  CAA = [
    # Let's Encrypt
    (CAA { name = "@"; tag = "issue"; value = "letsencrypt.org"; })
    (CAA { name = "@"; tag = "issuewild"; value = "letsencrypt.org"; })
    # BuyPass
    (CAA { name = "@"; tag = "issue"; value = "buypass.com"; })
    (CAA { name = "@"; tag = "issuewild"; value = "buypass.com"; })
    # ZeroSSL
    (CAA { name = "@"; tag = "issue"; value = "sectigo.com"; })
    (CAA { name = "@"; tag = "issuewild"; value = "sectigo.com"; })
  ];

  Normal = domain: forEachHost
    (n: v: mapAddresses { name = "${n}.${domain}."; addresses = v.public; })
  ;

  SSHFP = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (v.ssh.rsa != "") [
      (SSHFP_RSA_SHA1 { name = "${n}.${domain}."; pubkey = v.ssh.rsa; })
      (SSHFP_RSA_SHA256 { name = "${n}.${domain}."; pubkey = v.ssh.rsa; })
    ]
    ++ pkgs.lib.optionals (v.ssh.ed25519 != "") [
      (SSHFP_ED25519_SHA1 { name = "${n}.${domain}."; pubkey = v.ssh.ed25519; })
      (SSHFP_ED25519_SHA256 { name = "${n}.${domain}."; pubkey = v.ssh.ed25519; })
    ])
  ;

  TXT = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (v.role == roles.server) [
      (TXT { name = "hosts.${domain}."; contents = "${n}.${domain}"; })
    ])
  ;

  LTNet = domain: forEachHost
    (n: v: mapAddresses { name = "${n}.${domain}."; addresses = v.ltnet; })
  ;

  LTNetReverseIPv4 = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (v.ltnet.IPv4Prefix != "") [
      (PTR { name = v.ltnet.IPv4; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
  ;

  LTNetReverseIPv6 = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (v.ltnet.IPv6Prefix != "") [
      (PTR { name = v.ltnet.IPv6; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
  ;

  DN42 = domain: forEachHost
    (n: v: (
      pkgs.lib.optionals (v.role == roles.server) (
        (mapAddresses { name = "${n}.${domain}."; addresses = v.dn42; })
        # A record
        ++ pkgs.lib.optionals (v.dn42.IPv4 != "") [
          (A { name = "dns-authoritative.${n}.${domain}."; address = v.dn42.IPv4; })
        ]
        # AAAA record
        ++ pkgs.lib.optionals (v.dn42.IPv6 != "") [
          (AAAA { name = "dns-recursive.${n}.${domain}."; address = "${v.ltnet.IPv6Prefix}::53"; })
          (AAAA { name = "dns-authoritative.${n}.${domain}."; address = "${v.ltnet.IPv6Prefix}::54"; })
          (AAAA { name = "dns-authoritative-backend.${n}.${domain}."; address = "${v.ltnet.IPv6Prefix}::55"; })
        ]
      )))
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
        pkgs.lib.optionals (inRange && v.dn42.IPv4 != "") [
          (PTR { name = lastPart v.dn42.IPv4; target = "${ptrPrefix v}${n}.${domain}."; })
        ]);

  DN42ReverseIPv6 = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (v.dn42.IPv6 != "") [
      (PTR { name = v.dn42.IPv6; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
  ;

  NeoNetwork = domain: forEachHost
    (n: v: mapAddresses { name = "${n}.${domain}."; addresses = v.neonetwork; })
  ;

  NeoNetworkReverseIPv4 = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (v.neonetwork.IPv4 != "") [
      (PTR { name = v.neonetwork.IPv4; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
  ;

  NeoNetworkReverseIPv6 = domain: forEachActiveHost
    (n: v: pkgs.lib.optionals (v.neonetwork.IPv6 != "") [
      (PTR { name = v.neonetwork.IPv6; target = "${ptrPrefix v}${n}.${domain}."; reverse = true; })
    ])
  ;
}
