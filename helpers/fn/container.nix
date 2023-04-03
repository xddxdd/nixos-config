{
  config,
  pkgs,
  lib,
  hosts,
  this,
  constants,
  inputs,
  ...
}: let
  hostConfig = config;
in
  {
    name,
    ipSuffix,
    outerConfig ? {},
    innerConfig ? {},
    announcedIPv4 ? [],
    announcedIPv6 ? [],
  }:
    lib.recursiveUpdate outerConfig {
      autoStart = true;
      ephemeral = true;
      additionalCapabilities = ["CAP_NET_ADMIN"];

      privateNetwork = true;
      hostAddress = this.ltnet.IPv4;
      hostAddress6 = this.ltnet.IPv6;
      localAddress = "${this.ltnet.IPv4Prefix}.${ipSuffix}";
      localAddress6 = "${this.ltnet.IPv6Prefix}::${ipSuffix}";

      bindMounts = {
        "/nix/persistent" = {
          hostPath = "/nix/persistent";
          isReadOnly = true;
        };
      };

      config = {config, ...}: {
        age.identityPaths = ["/nix/persistent/etc/ssh/ssh_host_ed25519_key"];

        users.users.container = hostConfig.users.users.container;
        users.groups.container = hostConfig.users.groups.container;

        system.stateVersion = hostConfig.system.stateVersion;
        nixpkgs.pkgs = pkgs;
        networking.hostName = hostConfig.networking.hostName;
        networking.firewall.enable = false;

        imports = [
          inputs.agenix.nixosModules.age
          (innerConfig {containerConfig = config;})
        ];

        services.bird2 = {
          enable = (builtins.length (announcedIPv4 ++ announcedIPv6)) > 0;
          checkConfig = false;
          config =
            ''
              log stderr { error, fatal };
              router id ${this.ltnet.IPv4Prefix}.${ipSuffix};
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
            ''
            + (lib.concatStrings (builtins.map
              (ip: ''
                route ${ip}/32 unreachable;
              '')
              announcedIPv4))
            + ''
              }

              protocol static {
                ipv6;
            ''
            + (lib.concatStrings (builtins.map
              (ip: ''
                route ${ip}/128 unreachable;
              '')
              announcedIPv6))
            + ''
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

          address =
            (builtins.map (ip: "${ip}/32") announcedIPv4)
            ++ (builtins.map (ip: "${ip}/128") announcedIPv6);
        };
      };
    }