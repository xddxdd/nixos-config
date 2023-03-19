{
  pkgs,
  lib,
  LT,
  config,
  options,
  utils,
  inputs,
  ...
} @ args: {
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
    index = lib.mkOption {
      type = lib.types.int;
    };
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
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
      country = lib.mkOption {
        type = lib.types.str;
      };
      name = lib.mkOption {
        type = lib.types.str;
      };
      sanitized = lib.mkOption {
        type = lib.types.str;
      };
      lat = lib.mkOption {
        type = lib.types.str;
      };
      lng = lib.mkOption {
        type = lib.types.str;
      };
    };

    # SSH pubkey
    ssh.rsa = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    ssh.ed25519 = lib.mkOption {
      type = lib.types.str;
      default = "";
    };

    # Networking
    public = {
      IPv4 = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      IPv6 = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      IPv6Alt = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      IPv6Subnet = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };

    ltnet = {
      alone = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      IPv4 = lib.mkOption {
        type = lib.types.str;
        default = "${config.ltnet.IPv4Prefix}.1";
      };
      IPv4Prefix = lib.mkOption {
        type = lib.types.str;
        default = "172.18.${builtins.toString config.index}";
      };
      IPv6 = lib.mkOption {
        type = lib.types.str;
        default = "${config.ltnet.IPv6Prefix}::1";
      };
      IPv6Prefix = lib.mkOption {
        type = lib.types.str;
        default = "fdbc:f9dc:67ad:${builtins.toString config.index}";
      };
    };

    dn42 = {
      IPv4 = lib.mkOption {
        type = lib.types.str;
      };
      IPv6 = lib.mkOption {
        type = lib.types.str;
        default = "fdbc:f9dc:67ad:${builtins.toString config.index}::1";
      };
      region = lib.mkOption {
        type = lib.types.int;
      };
    };

    neonetwork = {
      IPv4 = lib.mkOption {
        type = lib.types.str;
        default = "10.127.10.${builtins.toString config.index}";
      };
      IPv6 = lib.mkOption {
        type = lib.types.str;
        default = "fd10:127:10:${builtins.toString config.index}::1";
      };
    };
  };
}
