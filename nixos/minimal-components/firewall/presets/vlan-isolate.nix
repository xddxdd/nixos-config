{
  lib,
  LT,
  config,
  ...
}:
let
  cfg = config.lantian.firewall.presets.vlan-isolate;
in
{
  options.lantian.firewall.presets.vlan-isolate = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Isolate VLANs on a shared interface from each other, allowing only the configured exceptions.";
    };
    interfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "eth0*" ];
      description = "Interface match expressions whose intra-interface traffic is isolated.";
    };
    allowTcpPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [
        9993
        22000
        111
        2049
      ];
      description = "Allowed TCP ports (ZeroTier, Syncthing, NFS).";
    };
    allowUdpPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [
        9993
        22000
        111
        2049
      ];
      description = "Allowed UDP ports (ZeroTier, Syncthing, NFS).";
    };
    allowDestIPs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Destination IPv4 addresses reachable across VLANs.";
    };
    allowFromInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Source interfaces allowed to reach everything (e.g. user VLAN).";
    };
    allowInterfacePairs = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            from = lib.mkOption {
              type = lib.types.str;
              description = "Source interface.";
            };
            to = lib.mkOption {
              type = lib.types.str;
              description = "Destination interface.";
            };
          };
        }
      );
      default = [ ];
      description = "Source/destination interface pairs allowed to talk (e.g. homelab VLAN to IoT VLAN).";
    };
  };

  config = lib.mkIf cfg.enable {
    lantian.firewall.chains.FILTER_FORWARD.rules = [
      {
        # Runs before the zone dispatch so intra-VLAN isolation is not
        # bypassed by the LAN zone's forward accept.
        priority = LT.firewallPriorities.service - 50;
        text = lib.concatStringsSep "\n" (
          map (i: "iifname ${i} oifname ${i} jump VLAN_ISOLATE") cfg.interfaces
        );
      }
    ];
    lantian.firewall.chains.VLAN_ISOLATE.rules = [
      {
        priority = LT.firewallPriorities.early;
        text = ''
          tcp dport { ${lib.concatStringsSep ", " (map builtins.toString cfg.allowTcpPorts)} } accept
          udp dport { ${lib.concatStringsSep ", " (map builtins.toString cfg.allowUdpPorts)} } accept
        '';
      }
      {
        priority = LT.firewallPriorities.preService;
        text = lib.concatStringsSep "\n" (map (ip: "ip daddr ${ip} accept") cfg.allowDestIPs);
      }
      {
        priority = LT.firewallPriorities.service;
        text = lib.concatStringsSep "\n" (
          (map (i: "iifname ${i} accept") cfg.allowFromInterfaces)
          ++ (map (p: "iifname ${p.from} oifname ${p.to} accept") cfg.allowInterfacePairs)
        );
      }
      {
        priority = LT.firewallPriorities.terminal;
        text = "reject with icmpx type admin-prohibited";
      }
    ];
  };
}
