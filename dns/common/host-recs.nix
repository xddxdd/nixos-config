{
  pkgs,
  lib,
  dns,
  hosts,
  ...
}:
with dns; let
  constants = pkgs.callPackage ../../helpers/constants.nix {};
  inherit (constants) tags;

  replacedHosts = {
    "50kvm" = hosts."v-ps-hkg";
    gigsgigscloud = hosts."v-ps-hkg";
    linkin = hosts."v-ps-hkg";
    hostdare = hosts."v-ps-sjc";
    soyoustart = hosts."oneprovider";
    virmach-ny3ip = hosts."virmach-ny6g";
    virtono = hosts."buyvm";
  };

  forEachActiveHost = mapFunc: (lib.mapAttrsToList mapFunc hosts);
  forEachHost = mapFunc: (lib.mapAttrsToList mapFunc (hosts // replacedHosts));

  ptrPrefix = v:
    if v.city != null
    then "${lib.replaceStrings ["_"] ["-"] v.city.sanitized}."
    else "";

  hasPublicIP = v: v.public.IPv4 != "" || v.public.IPv6 != "";

  mapAddresses = {
    name,
    addresses,
    ttl ? "1d",
  }:
  # A record
    lib.optionals (addresses.IPv4 != "") [
      (A {
        name = "${name}";
        address = addresses.IPv4;
        inherit ttl;
      })
      (A {
        name = "v4.${name}";
        address = addresses.IPv4;
        inherit ttl;
      })
    ]
    # AAAA record
    ++ lib.optionals (addresses.IPv6 != "") [
      (AAAA {
        name = "${name}";
        address = addresses.IPv6;
        inherit ttl;
      })
      (AAAA {
        name = "v6.${name}";
        address = addresses.IPv6;
        inherit ttl;
      })
    ]
    ++ lib.optionals (addresses.IPv6Alt or "" != "") [
      (AAAA {
        name = "${name}";
        address = addresses.IPv6Alt;
        inherit ttl;
      })
      (AAAA {
        name = "v6.${name}";
        address = addresses.IPv6Alt;
        inherit ttl;
      })
    ]
    ++ [
      (CNAME {
        name = "*.${name}";
        target = name;
        inherit ttl;
      })
    ];
in {
  inherit hasPublicIP mapAddresses;

  fakeALIAS = {
    name,
    target,
    ttl ? "1d",
  }: let
    addresses = hosts."${target}".public;
    ttl = "1d";
  in
    # A record
    lib.optionals (addresses.IPv4 != "") [
      (A {
        name = "${name}";
        address = addresses.IPv4;
        inherit ttl;
      })
    ]
    # AAAA record
    ++ lib.optionals (addresses.IPv6 != "") [
      (AAAA {
        name = "${name}";
        address = addresses.IPv6;
        inherit ttl;
      })
    ]
    ++ lib.optionals (addresses.IPv6Alt or "" != "") [
      (AAAA {
        name = "${name}";
        address = addresses.IPv6Alt;
        inherit ttl;
      })
    ];

  CAA = [
    # Let's Encrypt
    (CAA {
      name = "@";
      tag = "issue";
      value = "letsencrypt.org";
    })
    (CAA {
      name = "@";
      tag = "issuewild";
      value = "letsencrypt.org";
    })
    # BuyPass
    (CAA {
      name = "@";
      tag = "issue";
      value = "buypass.com";
    })
    (CAA {
      name = "@";
      tag = "issuewild";
      value = "buypass.com";
    })
    # Google
    (CAA {
      name = "@";
      tag = "issue";
      value = "pki.goog; cansignhttpexchanges=yes";
    })
    (CAA {
      name = "@";
      tag = "issuewild";
      value = "pki.goog; cansignhttpexchanges=yes";
    })
    # ZeroSSL
    (CAA {
      name = "@";
      tag = "issue";
      value = "sectigo.com";
    })
    (CAA {
      name = "@";
      tag = "issuewild";
      value = "sectigo.com";
    })
  ];

  Normal = domain:
    forEachHost
    (n: v:
      mapAddresses {
        name = "${n}.${domain}.";
        addresses =
          if hasPublicIP v
          then v.public
          else v.ltnet;
      });

  SSHFP = domain:
    forEachActiveHost
    (n: v:
      lib.optionals (v.ssh.rsa != "") [
        (SSHFP_RSA_SHA1 {
          name = "${n}.${domain}.";
          pubkey = v.ssh.rsa;
        })
        (SSHFP_RSA_SHA256 {
          name = "${n}.${domain}.";
          pubkey = v.ssh.rsa;
        })
      ]
      ++ lib.optionals (v.ssh.ed25519 != "") [
        (SSHFP_ED25519_SHA1 {
          name = "${n}.${domain}.";
          pubkey = v.ssh.ed25519;
        })
        (SSHFP_ED25519_SHA256 {
          name = "${n}.${domain}.";
          pubkey = v.ssh.ed25519;
        })
      ]);

  GeoInfo = args:
    TXT ({
        contents = builtins.toJSON (builtins.mapAttrs
          (k: v: {
            inherit (v.city) lat lng;
            a = lib.optional (v.public.IPv4 != "") v.public.IPv4;
            aaaa =
              (lib.optional (v.public.IPv6 != "") v.public.IPv6)
              ++ (lib.optional (v.public.IPv6Alt != "") v.public.IPv6Alt);
          })
          (lib.filterAttrs
            (n: v:
              (builtins.elem tags.server v.tags)
              && (builtins.elem tags.public-facing v.tags))
            hosts));
      }
      // args);

  LTNet = domain:
    forEachHost
    (n: v:
      mapAddresses {
        name = "${n}.${domain}.";
        addresses = v.ltnet;
      });

  LTNetReverseIPv4 = domain:
    forEachActiveHost
    (n: v:
      lib.optionals (v.ltnet.IPv4Prefix != "") [
        (PTR {
          name = v.ltnet.IPv4;
          target = "${ptrPrefix v}${n}.${domain}.";
          reverse = true;
        })
      ]);

  LTNetReverseIPv6 = domain:
    forEachActiveHost
    (n: v:
      lib.optionals (v.ltnet.IPv6Prefix != "") [
        (PTR {
          name = v.ltnet.IPv6;
          target = "${ptrPrefix v}${n}.${domain}.";
          reverse = true;
        })
      ]);

  DN42 = domain:
    forEachHost
    (n: v: (
      lib.optionals (builtins.elem tags.server v.tags) (
        (mapAddresses {
          name = "${n}.${domain}.";
          addresses = v.dn42;
        })
        # A record
        ++ lib.optionals (v.dn42.IPv4 != "") [
          (A {
            name = "dns-authoritative.${n}.${domain}.";
            address = v.dn42.IPv4;
          })
        ]
        # AAAA record
        ++ lib.optionals (v.dn42.IPv6 != "") [
          (AAAA {
            name = "dns-recursive.${n}.${domain}.";
            address = "${v.ltnet.IPv6Prefix}::53";
          })
          (AAAA {
            name = "dns-authoritative.${n}.${domain}.";
            address = "${v.ltnet.IPv6Prefix}::54";
          })
          (AAAA {
            name = "dns-authoritative-backend.${n}.${domain}.";
            address = "${v.ltnet.IPv6Prefix}::55";
          })
        ]
      )
    ));

  # Special handling: split for IP ranges & keep only last part of IP
  DN42ReverseIPv4 = let
    lastPart = ip: builtins.elemAt (lib.splitString "." ip) 3;
  in
    domain: ipMin: ipMax:
      forEachActiveHost
      (n: v: let
        i = lib.toInt (lastPart v.dn42.IPv4);
        inRange = i >= ipMin && i <= ipMax;
      in
        lib.optionals (inRange && v.dn42.IPv4 != "") [
          (PTR {
            name = lastPart v.dn42.IPv4;
            target = "${ptrPrefix v}${n}.${domain}.";
          })
        ]);

  DN42ReverseIPv6 = domain:
    forEachActiveHost
    (n: v:
      lib.optionals (v.dn42.IPv6 != "") [
        (PTR {
          name = v.dn42.IPv6;
          target = "${ptrPrefix v}${n}.${domain}.";
          reverse = true;
        })
      ]);

  NeoNetwork = domain:
    forEachHost
    (n: v:
      mapAddresses {
        name = "${n}.${domain}.";
        addresses = v.neonetwork;
      });

  NeoNetworkReverseIPv4 = domain:
    forEachActiveHost
    (n: v:
      lib.optionals (v.neonetwork.IPv4 != "") [
        (PTR {
          name = v.neonetwork.IPv4;
          target = "${ptrPrefix v}${n}.${domain}.";
          reverse = true;
        })
      ]);

  NeoNetworkReverseIPv6 = domain:
    forEachActiveHost
    (n: v:
      lib.optionals (v.neonetwork.IPv6 != "") [
        (PTR {
          name = v.neonetwork.IPv6;
          target = "${ptrPrefix v}${n}.${domain}.";
          reverse = true;
        })
      ]);
}
