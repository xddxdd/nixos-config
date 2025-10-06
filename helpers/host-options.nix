{
  lib,
  config,
  constants,
  options,
  ...
}@args:
{
  options = {
    name = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = args.name;
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "${config.name}.lantian.pub";
    };
    index = lib.mkOption { type = lib.types.int; };
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    hasTag = lib.mkOption {
      readOnly = true;
      default = tag: builtins.elem tag config.tags;
    };
    sshPort = lib.mkOption {
      type = lib.types.int;
      default = 2222;
    };
    system = lib.mkOption {
      type = lib.types.str;
      default = "x86_64-linux";
    };
    manualDeploy = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    cpuThreads = lib.mkOption {
      type = lib.types.int;
      default = 0;
    };

    # Geolocation
    city = {
      country = lib.mkOption { type = lib.types.str; };
      name = lib.mkOption { type = lib.types.str; };
      sanitized = lib.mkOption { type = lib.types.str; };
      lat = lib.mkOption { type = lib.types.str; };
      lng = lib.mkOption { type = lib.types.str; };

      # Extra fields from cities.json
      admin1 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      admin2 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };

    # SSH pubkey
    ssh.rsa = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    ssh.ed25519 = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    # LTNET Networking
    zerotier = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    # Networking
    public = {
      IPv4 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      IPv6 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      IPv6Alt = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      IPv6Subnet = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };

    firewalled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether node is firewalled from Internet despite having public IP.";
    };

    ltnet = {
      IPv4 = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "198.18.0.${builtins.toString config.index}";
      };
      IPv4Prefix = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "198.18.${builtins.toString config.index}";
      };
      IPv4PrefixAlt = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "198.19.${builtins.toString config.index}";
      };
      IPv6 = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "fdbc:f9dc:67ad::${builtins.toString config.index}";
      };
      IPv6Prefix = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "fdbc:f9dc:67ad:${builtins.toString config.index}";
      };
    };

    dn42 = {
      IPv4 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      IPv6 = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "fdbc:f9dc:67ad:${builtins.toString config.index}::1";
      };
      IPv6Prefix = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "fdbc:f9dc:67ad:${builtins.toString config.index}";
      };
      region = lib.mkOption { type = lib.types.int; };
    };

    neonetwork = {
      IPv4 = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "10.127.10.${builtins.toString config.index}";
      };
      IPv6 = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "fd10:127:10:${builtins.toString config.index}::1";
      };
      IPv6Prefix = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "fd10:127:10:${builtins.toString config.index}";
      };
    };

    wg-lantian = {
      forwardStart = lib.mkOption {
        readOnly = true;
        type = lib.types.int;
        default = constants.port.WGLanTian.ForwardStart + (config.index - 1) * 10;
      };
      forwardStop = lib.mkOption {
        readOnly = true;
        type = lib.types.int;
        default = constants.port.WGLanTian.ForwardStart + config.index * 10 - 1;
      };
    };

    additionalRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    _addresses = lib.mkOption {
      readOnly = true;
      default = lib.unique (
        lib.optionals (config.ltnet.IPv4 != null) [ (config.ltnet.IPv4 + "/32") ]
        ++ lib.optionals (config.ltnet.IPv4Prefix != null) [ (config.ltnet.IPv4Prefix + ".1/32") ]
        ++ lib.optionals (config.ltnet.IPv4PrefixAlt != null) [ (config.ltnet.IPv4PrefixAlt + ".1/32") ]
        ++ lib.optionals (config.ltnet.IPv6 != null) [ (config.ltnet.IPv6 + "/128") ]
        ++ lib.optionals (config.dn42.IPv4 != null) [ (config.dn42.IPv4 + "/32") ]
        ++ lib.optionals (config.dn42.IPv6 != null) [ (config.dn42.IPv6 + "/128") ]
        ++ lib.optionals (config.neonetwork.IPv4 != null) [ (config.neonetwork.IPv4 + "/32") ]
        ++ lib.optionals (config.neonetwork.IPv6 != null) [ (config.neonetwork.IPv6 + "/128") ]
      );
    };
    _addresses4 = lib.mkOption {
      readOnly = true;
      default = builtins.filter (addr: !lib.hasInfix ":" addr) config._addresses;
    };
    _addresses6 = lib.mkOption {
      readOnly = true;
      default = builtins.filter (addr: !lib.hasInfix ":" addr) config._addresses;
    };

    _routes = lib.mkOption {
      readOnly = true;
      default = lib.unique (
        lib.optionals (config.ltnet.IPv4 != null) [ (config.ltnet.IPv4 + "/32") ]
        ++ lib.optionals (config.ltnet.IPv4Prefix != null) [ (config.ltnet.IPv4Prefix + ".0/24") ]
        ++ lib.optionals (config.ltnet.IPv4PrefixAlt != null) [ (config.ltnet.IPv4PrefixAlt + ".0/24") ]
        ++ lib.optionals (config.ltnet.IPv6Prefix != null) [ (config.ltnet.IPv6Prefix + "::/64") ]
        ++ lib.optionals (config.dn42.IPv4 != null) [ (config.dn42.IPv4 + "/32") ]
        ++ lib.optionals (config.dn42.IPv6Prefix != null) [ (config.dn42.IPv6Prefix + "::/64") ]
        ++ lib.optionals (config.neonetwork.IPv4 != null) [ (config.neonetwork.IPv4 + "/32") ]
        ++ lib.optionals (config.neonetwork.IPv6Prefix != null) [ (config.neonetwork.IPv6Prefix + "::/64") ]
        ++ config.additionalRoutes
      );
    };
    _routes4 = lib.mkOption {
      readOnly = true;
      default = builtins.filter (route: !lib.hasInfix ":" route) config._routes;
    };
    _routes6 = lib.mkOption {
      readOnly = true;
      default = builtins.filter (route: lib.hasInfix ":" route) config._routes;
    };
  };
}
