{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{ containerIP
, outerConfig ? { }
, innerConfig ? { }
, announcedIPv4 ? [ ]
, announcedIPv6 ? [ ]
,
}:
outerConfig // {
  autoStart = true;
  ephemeral = true;
  additionalCapabilities = [ "CAP_NET_ADMIN" ];

  privateNetwork = true;
  hostAddress = "${thisHost.ltnet.IPv4Prefix}.1";
  hostAddress6 = "${thisHost.ltnet.IPv6Prefix}::1";
  localAddress = "${thisHost.ltnet.IPv4Prefix}.${builtins.toString containerIP}";
  localAddress6 = "${thisHost.ltnet.IPv6Prefix}::${builtins.toString containerIP}";

  config = { ... }: innerConfig // {
    system.stateVersion = config.system.stateVersion;
    nixpkgs.pkgs = pkgs;
    networking.hostName = config.networking.hostName;
    networking.firewall.enable = false;
    services.journald.extraConfig = ''
      SystemMaxUse=50M
      SystemMaxFileSize=10M
    '';

    services.bird2 = {
      enable = true;
      checkConfig = false;
      config = ''
        log stderr { error, fatal };
        router id ${thisHost.ltnet.IPv4Prefix}.${builtins.toString containerIP};
        protocol device {}

        protocol babel {
          ipv4 {
            import none;
            export all;
          };
          ipv6 {
            import none;
            export all;
          };
          interface "eth*" {
            type wired;
            hello interval 1s;
            update interval 1s;
            port 6695;
          };
        }

        protocol static {
          ipv4;
      '' + (pkgs.lib.concatStrings (builtins.map
        (ip: ''
          route ${ip}/32 unreachable;
        '')
        announcedIPv4)) + ''
        }

        protocol static {
          ipv6;
      '' + (pkgs.lib.concatStrings (builtins.map
        (ip: ''
          route ${ip}/128 unreachable;
        '')
        announcedIPv6)) + ''
        }
      '';
    };

    services.resolved.enable = false;

    systemd.network.enable = true;
    systemd.network.netdevs.dummy0 = {
      netdevConfig = {
        Kind = "dummy";
        Name = "dummy0";
      };
    };

    systemd.network.networks.dummy0 = {
      matchConfig = {
        Name = "dummy0";
      };

      networkConfig = {
        IPv6PrivacyExtensions = false;
      };

      addresses = (builtins.map
        (ip: {
          addressConfig = { Address = "${ip}/32"; };
        })
        announcedIPv4) ++ (builtins.map
        (ip: {
          addressConfig = { Address = "${ip}/128"; };
        })
        announcedIPv6);
    };
  };
}
