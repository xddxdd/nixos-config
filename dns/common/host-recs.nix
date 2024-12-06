{
  pkgs,
  config,
  lib,
  LT,
  ...
}:
let
  constants = pkgs.callPackage ../../helpers/constants.nix { };
  inherit (constants) tags;

  replacedHosts = {
    "50kvm" = LT.hosts."v-ps-hkg";
    gigsgigscloud = LT.hosts."v-ps-hkg";
    hostdare = LT.hosts."bwg-lax";
    linkin = LT.hosts."v-ps-hkg";
    oneprovider = LT.hosts."hetzner-de";
    soyoustart = LT.hosts."hetzner-de";
    v-ps-sjc = LT.hosts."bwg-lax";
    virmach-ny3ip = LT.hosts."virmach-ny6g";
    virtono = LT.hosts."buyvm";
  };

  forEachActiveHost = mapFunc: (lib.mapAttrsToList mapFunc LT.hosts);
  forEachHost = mapFunc: (lib.mapAttrsToList mapFunc (LT.hosts // replacedHosts));

  ptrPrefix =
    v: if v.city != null then "${lib.replaceStrings [ "_" ] [ "-" ] v.city.sanitized}." else "";

  hasPublicIP = v: v.public.IPv4 != "" || v.public.IPv6 != "";

  concatDomain = prefix: domain: if domain == "@" then prefix else "${prefix}.${domain}";

  mapAddresses =
    {
      name,
      addresses,
      ttl ? "1h",
    }:
    # A record
    lib.optionals (addresses.IPv4 != "") [
      {
        recordType = "A";
        inherit name;
        address = addresses.IPv4;
        inherit ttl;
      }
      {
        recordType = "A";
        name = concatDomain "v4" name;
        address = addresses.IPv4;
        inherit ttl;
      }
    ]
    # AAAA record
    ++ lib.optionals (addresses.IPv6 != "") [
      {
        recordType = "AAAA";
        inherit name;
        address = addresses.IPv6;
        inherit ttl;
      }
      {
        recordType = "AAAA";
        name = concatDomain "v6" name;
        address = addresses.IPv6;
        inherit ttl;
      }
    ]
    ++ lib.optionals (addresses.IPv6Alt or "" != "") [
      {
        recordType = "AAAA";
        inherit name;
        address = addresses.IPv6Alt;
        inherit ttl;
      }
      {
        recordType = "AAAA";
        name = concatDomain "v6" name;
        address = addresses.IPv6Alt;
        inherit ttl;
      }
    ]
    ++ [
      {
        recordType = "CNAME";
        name = concatDomain "*" name;
        target = name;
        inherit ttl;
      }
    ];
in
{
  recordHandlers = {
    fakeALIAS =
      { target, ... }@args:
      let
        addresses = LT.hosts."${target}".public;
      in
      # A record
      (lib.optionals (addresses.IPv4 != "") (
        config.recordHandlers.A (
          args
          // {
            recordType = "A";
            address = addresses.IPv4;
          }
        )
      ))
      # AAAA record
      ++ (lib.optionals (addresses.IPv6 != "") (
        config.recordHandlers.AAAA (
          args
          // {
            recordType = "AAAA";
            address = addresses.IPv6;
          }
        )
      ))
      ++ (lib.optionals (addresses.IPv6Alt or "" != "") (
        config.recordHandlers.AAAA (
          args
          // {
            recordType = "AAAA";
            address = addresses.IPv6Alt;
          }
        )
      ));

    GEO =
      { filter, ... }@args:
      let
        geodnsFilter = "country,false;default,false;geodistance,false;first_n,false,1";

        meta =
          k: v:
          {
            gcore_filters = geodnsFilter;
            gcore_latitude = "${builtins.toString v.city.lat}";
            gcore_longitude = "${builtins.toString v.city.lng}";
            gcore_notes = k;
          }
          // (lib.optionalAttrs (builtins.hasAttr "healthcheck" args) {
            gcore_filters = "healthcheck,false;${geodnsFilter}";
            gcore_failover_protocol = "HTTP";
            gcore_failover_port = "443";
            gcore_failover_frequency = "30";
            gcore_failover_timeout = "10";
            gcore_failover_method = "GET";
            gcore_failover_url = "/";
            gcore_failover_tls = "true";
            gcore_failover_host = args.healthcheck;
          })
          // (lib.optionalAttrs (k == "bwg-lax") {
            gcore_countries = "CN";
          });
      in
      lib.flatten (
        lib.mapAttrsToList (
          k: v:
          (lib.optional (v.public.IPv4 != "") (
            config.recordHandlers.A (
              args
              // {
                recordType = "A";
                address = v.public.IPv4;
                meta = meta k v;
              }
            )
          ))
          ++ (lib.optional (v.public.IPv6 != "") (
            config.recordHandlers.AAAA (
              args
              // {
                recordType = "AAAA";
                address = v.public.IPv6;
                meta = meta k v;
              }
            )
          ))
        ) (lib.filterAttrs filter LT.hosts)
      );
  };

  common.concatDomain = concatDomain;

  common.hostRecs = {
    inherit hasPublicIP mapAddresses;

    CAA = [
      # Email notification
      {
        recordType = "CAA";
        name = "@";
        tag = "iodef";
        value = "mailto:b980120@hotmail.com";
      }
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

    Normal =
      domain:
      forEachHost (
        n: v:
        mapAddresses {
          name = concatDomain n domain;
          addresses = if hasPublicIP v then v.public else v.ltnet;
        }
      );

    SSHFP =
      domain:
      forEachActiveHost (
        n: v:
        lib.optionals (v.ssh.rsa != "") [
          {
            recordType = "SSHFP_RSA_SHA1";
            name = concatDomain n domain;
            pubkey = v.ssh.rsa;
          }
          {
            recordType = "SSHFP_RSA_SHA256";
            name = concatDomain n domain;
            pubkey = v.ssh.rsa;
          }
        ]
        ++ lib.optionals (v.ssh.ed25519 != "") [
          {
            recordType = "SSHFP_ED25519_SHA1";
            name = concatDomain n domain;
            pubkey = v.ssh.ed25519;
          }
          {
            recordType = "SSHFP_ED25519_SHA256";
            name = concatDomain n domain;
            pubkey = v.ssh.ed25519;
          }
        ]
      );

    LTNet =
      domain:
      forEachHost (
        n: v:
        mapAddresses {
          name = concatDomain n domain;
          addresses = v.ltnet;
        }
      );

    LTNetReverseIPv4_16 =
      domain:
      assert lib.hasSuffix "." domain;
      forEachActiveHost (
        n: v: [
          {
            recordType = "PTR";
            name = "*.${builtins.toString v.index}";
            target = concatDomain "${ptrPrefix v}${n}" domain;
          }
        ]
      );

    LTNetReverseIPv4_24 =
      domain:
      assert lib.hasSuffix "." domain;
      forEachActiveHost (
        n: v: [
          {
            recordType = "PTR";
            name = builtins.toString v.index;
            target = concatDomain "${ptrPrefix v}${n}" domain;
          }
        ]
      );

    LTNetReverseIPv6_64 =
      domain:
      assert lib.hasSuffix "." domain;
      forEachActiveHost (
        n: v:
        let
          prepend = s: if (builtins.length s) < 4 then prepend ([ "0" ] ++ s) else s;
          indexList = prepend (lib.stringToCharacters (builtins.toString v.index));
          indexInterspersed = lib.intersperse "." indexList;
          indexStr = lib.concatStrings (lib.reverseList indexInterspersed);
        in
        [
          {
            recordType = "PTR";
            name = "*.${indexStr}";
            target = concatDomain "${ptrPrefix v}${n}" domain;
          }
        ]
      );

    DN42 =
      domain:
      forEachHost (
        n: v:
        (lib.optionals (v.hasTag tags.server) (
          (mapAddresses {
            name = concatDomain n domain;
            addresses = v.dn42;
          })
          # A record
          ++ lib.optionals (v.dn42.IPv4 != "") [
            {
              recordType = "A";
              name = concatDomain "dns-authoritative.${n}" domain;
              address = v.dn42.IPv4;
            }
          ]
          # AAAA record
          ++ lib.optionals (v.dn42.IPv6 != "") [
            {
              recordType = "AAAA";
              name = concatDomain "dns-recursive.${n}" domain;
              address = "${v.ltnet.IPv6Prefix}::53";
            }
            {
              recordType = "AAAA";
              name = concatDomain "dns-authoritative.${n}" domain;
              address = "${v.ltnet.IPv6Prefix}::54";
            }
            {
              recordType = "AAAA";
              name = concatDomain "dns-authoritative-backend.${n}" domain;
              address = "${v.ltnet.IPv6Prefix}::55";
            }
          ]
        ))
      );

    # Special handling: split for IP ranges & keep only last part of IP
    DN42ReverseIPv4 =
      let
        lastPart = ip: builtins.elemAt (lib.splitString "." ip) 3;
      in
      domain: ipMin: ipMax:
      assert lib.hasSuffix "." domain;
      lib.mapAttrsToList (
        n: v:
        let
          i = lib.toInt (lastPart v.dn42.IPv4);
          inRange = i >= ipMin && i <= ipMax;
        in
        lib.optionals inRange [
          {
            recordType = "PTR";
            name = lastPart v.dn42.IPv4;
            target = concatDomain "${ptrPrefix v}${n}" domain;
          }
        ]
      ) (lib.filterAttrs (_n: v: v.dn42.IPv4 != "") LT.hosts);

    NeoNetwork =
      domain:
      forEachHost (
        n: v:
        mapAddresses {
          name = concatDomain n domain;
          addresses = v.neonetwork;
        }
      );
  };
}
