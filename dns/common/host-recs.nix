{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
} @ args: let
  constants = pkgs.callPackage ../../helpers/constants.nix {};
  inherit (constants) tags;

  replacedHosts = {
    "50kvm" = LT.hosts."v-ps-hkg";
    gigsgigscloud = LT.hosts."v-ps-hkg";
    linkin = LT.hosts."v-ps-hkg";
    hostdare = LT.hosts."v-ps-sjc";
    oneprovider = LT.hosts."v-ps-fal";
    soyoustart = LT.hosts."v-ps-fal";
    virmach-ny3ip = LT.hosts."virmach-ny6g";
    virtono = LT.hosts."buyvm";
  };

  forEachActiveHost = mapFunc: (lib.mapAttrsToList mapFunc LT.hosts);
  forEachHost = mapFunc: (lib.mapAttrsToList mapFunc (LT.hosts // replacedHosts));

  ptrPrefix = v:
    if v.city != null
    then "${lib.replaceStrings ["_"] ["-"] v.city.sanitized}."
    else "";

  hasPublicIP = v: v.public.IPv4 != "" || v.public.IPv6 != "";

  mapAddresses = {
    name,
    addresses,
    ttl ? "1h",
  }:
  # A record
    lib.optionals (addresses.IPv4 != "") [
      {
        recordType = "A";
        name = "${name}";
        address = addresses.IPv4;
        inherit ttl;
      }
      {
        recordType = "A";
        name = "v4.${name}";
        address = addresses.IPv4;
        inherit ttl;
      }
    ]
    # AAAA record
    ++ lib.optionals (addresses.IPv6 != "") [
      {
        recordType = "AAAA";
        name = "${name}";
        address = addresses.IPv6;
        inherit ttl;
      }
      {
        recordType = "AAAA";
        name = "v6.${name}";
        address = addresses.IPv6;
        inherit ttl;
      }
    ]
    ++ lib.optionals (addresses.IPv6Alt or "" != "") [
      {
        recordType = "AAAA";
        name = "${name}";
        address = addresses.IPv6Alt;
        inherit ttl;
      }
      {
        recordType = "AAAA";
        name = "v6.${name}";
        address = addresses.IPv6Alt;
        inherit ttl;
      }
    ]
    ++ [
      {
        recordType = "CNAME";
        name = "*.${name}";
        target = name;
        inherit ttl;
      }
    ];
in {
  recordHandlers = {
    fakeALIAS = {target, ...} @ args: let
      addresses = LT.hosts."${target}".public;
    in
      # A record
      (lib.optionals (addresses.IPv4 != "")
        (config.recordHandlers.A (args
          // {
            recordType = "A";
            address = addresses.IPv4;
          })))
      # AAAA record
      ++ (lib.optionals (addresses.IPv6 != "")
        (config.recordHandlers.AAAA (args
          // {
            recordType = "AAAA";
            address = addresses.IPv6;
          })))
      ++ (lib.optionals (addresses.IPv6Alt or "" != "")
        (config.recordHandlers.AAAA (
          args
          // {
            recordType = "AAAA";
            address = addresses.IPv6Alt;
          }
        )));

    GEO = {
      name,
      filter,
      ...
    } @ args:
      (config.recordHandlers.TXT
        (args
          // {
            recordType = "TXT";
            name = "geoinfo.${name}";
            contents = builtins.toJSON (builtins.mapAttrs
              (k: v: {
                inherit (v.city) lat lng;
                a = lib.optional (v.public.IPv4 != "") v.public.IPv4;
                aaaa =
                  (lib.optional (v.public.IPv6 != "") v.public.IPv6)
                  ++ (lib.optional (v.public.IPv6Alt != "") v.public.IPv6Alt);
              })
              (lib.filterAttrs filter LT.hosts));
          }))
      ++ (config.recordHandlers.IGNORE (args
        // {
          type = "A,AAAA";
          ttl = null;
        }));
  };

  common.hostRecs = {
    inherit hasPublicIP mapAddresses;

    CAA = [
      # Let's Encrypt
      {
        recordType = "CAA";
        name = "@";
        tag = "issue";
        value = "letsencrypt.org";
      }
      {
        recordType = "CAA";
        name = "@";
        tag = "issuewild";
        value = "letsencrypt.org";
      }
      # BuyPass
      {
        recordType = "CAA";
        name = "@";
        tag = "issue";
        value = "buypass.com";
      }
      {
        recordType = "CAA";
        name = "@";
        tag = "issuewild";
        value = "buypass.com";
      }
      # Google
      {
        recordType = "CAA";
        name = "@";
        tag = "issue";
        value = "pki.goog; cansignhttpexchanges=yes";
      }
      {
        recordType = "CAA";
        name = "@";
        tag = "issuewild";
        value = "pki.goog; cansignhttpexchanges=yes";
      }
      # ZeroSSL
      {
        recordType = "CAA";
        name = "@";
        tag = "issue";
        value = "sectigo.com";
      }
      {
        recordType = "CAA";
        name = "@";
        tag = "issuewild";
        value = "sectigo.com";
      }
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
          {
            recordType = "SSHFP_RSA_SHA1";
            name = "${n}.${domain}.";
            pubkey = v.ssh.rsa;
          }
          {
            recordType = "SSHFP_RSA_SHA256";
            name = "${n}.${domain}.";
            pubkey = v.ssh.rsa;
          }
        ]
        ++ lib.optionals (v.ssh.ed25519 != "") [
          {
            recordType = "SSHFP_ED25519_SHA1";
            name = "${n}.${domain}.";
            pubkey = v.ssh.ed25519;
          }
          {
            recordType = "SSHFP_ED25519_SHA256";
            name = "${n}.${domain}.";
            pubkey = v.ssh.ed25519;
          }
        ]);

    LTNet = domain:
      forEachHost
      (n: v:
        mapAddresses {
          name = "${n}.${domain}.";
          addresses = v.ltnet;
        });

    LTNetReverseIPv4_16 = domain:
      forEachActiveHost
      (n: v: [
        {
          recordType = "PTR";
          name = "*.${builtins.toString v.index}";
          target = "${ptrPrefix v}${n}.${domain}.";
        }
      ]);

    LTNetReverseIPv4_24 = domain:
      forEachActiveHost
      (n: v: [
        {
          recordType = "PTR";
          name = builtins.toString v.index;
          target = "${ptrPrefix v}${n}.${domain}.";
        }
      ]);

    LTNetReverseIPv6_64 = domain:
      forEachActiveHost
      (n: v: let
        prepend = s:
          if (builtins.length s) < 4
          then prepend (["0"] ++ s)
          else s;
        indexList = prepend (lib.stringToCharacters (builtins.toString v.index));
        indexInterspersed = lib.intersperse "." indexList;
        indexStr = lib.concatStrings (lib.reverseList indexInterspersed);
      in [
        {
          recordType = "PTR";
          name = "*.${indexStr}";
          target = "${ptrPrefix v}${n}.${domain}.";
        }
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
            {
              recordType = "A";
              name = "dns-authoritative.${n}.${domain}.";
              address = v.dn42.IPv4;
            }
          ]
          # AAAA record
          ++ lib.optionals (v.dn42.IPv6 != "") [
            {
              recordType = "AAAA";
              name = "dns-recursive.${n}.${domain}.";
              address = "${v.ltnet.IPv6Prefix}::53";
            }
            {
              recordType = "AAAA";
              name = "dns-authoritative.${n}.${domain}.";
              address = "${v.ltnet.IPv6Prefix}::54";
            }
            {
              recordType = "AAAA";
              name = "dns-authoritative-backend.${n}.${domain}.";
              address = "${v.ltnet.IPv6Prefix}::55";
            }
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
            {
              recordType = "PTR";
              name = lastPart v.dn42.IPv4;
              target = "${ptrPrefix v}${n}.${domain}.";
            }
          ]);

    NeoNetwork = domain:
      forEachHost
      (n: v:
        mapAddresses {
          name = "${n}.${domain}.";
          addresses = v.neonetwork;
        });
  };
}
