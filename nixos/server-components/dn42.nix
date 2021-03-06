{ pkgs, lib, config, options, ... }:

let
  myASN = 4242422547;
  myASNAbbr = 2547;

  LT = import ../../helpers { inherit config pkgs; };
  filterType = type: lib.filterAttrs (n: v: v.tunnel.type == type);

  setupAddressing = interfaceName: v: lib.optionalString (v.tunnel.mtu != null) ''
    ${pkgs.iproute2}/bin/ip link set ${interfaceName} mtu ${builtins.toString v.tunnel.mtu}
  '' + ''
    ${pkgs.iproute2}/bin/ip addr add ${v.addressing.myIPv6LinkLocal}/10 dev ${interfaceName}
  '' + lib.optionalString (v.addressing.peerIPv4 != null) ''
    ${pkgs.iproute2}/bin/ip addr add ${v.addressing.myIPv4} peer ${v.addressing.peerIPv4} dev ${interfaceName}
  '' + lib.optionalString (v.addressing.peerIPv6 != null) ''
    ${pkgs.iproute2}/bin/ip addr add ${v.addressing.myIPv6} peer ${v.addressing.peerIPv6} dev ${interfaceName}
    ${pkgs.iproute2}/bin/ip route add ${v.addressing.peerIPv6}/128 src ${v.addressing.myIPv6} dev ${interfaceName}
  '' + lib.optionalString (v.addressing.peerIPv6 == null) ''
    ${pkgs.iproute2}/bin/ip addr add ${v.addressing.myIPv6}/128 dev ${interfaceName}
  '' + lib.optionalString (v.addressing.myIPv6Subnet != null) ''
    ${pkgs.iproute2}/bin/ip addr add ${v.addressing.myIPv6Subnet}/${builtins.toString v.addressing.IPv6SubnetMask} dev ${interfaceName}
  '' + ''
    ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.${interfaceName}.autoconf=0
    ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.${interfaceName}.accept_ra=0
    ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.${interfaceName}.addr_gen_mode=1
  '';
in
{
  config.age.secrets.wg-priv.file = pkgs.secrets + "/wg-priv/${config.networking.hostName}.age";

  options.services.dn42 = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        # Basic configuration
        remoteASN = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };
        latencyMs = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };
        badRouting = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        # Peering (BGP) configuration
        peering = lib.mkOption {
          default = { };
          type = lib.types.submodule {
            options = {
              network = lib.mkOption {
                type = lib.types.enum [ "dn42" "neo" ];
                default = "dn42";
              };
              mpbgp = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };
            };
          };
        };

        # Tunnel configuration
        tunnel = lib.mkOption {
          default = { };
          type = lib.types.submodule {
            options = {
              type = lib.mkOption {
                type = lib.types.enum [ "openvpn" "wireguard" "gre" ];
                default = "gre";
              };
              localPort = lib.mkOption {
                type = lib.types.int;
                default = 0;
              };
              remotePort = lib.mkOption {
                type = lib.types.int;
                default = 20000 + myASNAbbr;
              };
              remoteAddress = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              wireguardPubkey = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              wireguardPresharedKeyFile = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
              };
              openvpnStaticKeyPath = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              mtu = lib.mkOption {
                type = lib.types.nullOr lib.types.int;
                default = null;
              };
            };
          };
        };

        # IP address inside tunnel
        addressing = lib.mkOption {
          default = { };
          type = lib.types.submodule {
            options = {
              peerIPv4 = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              peerIPv6 = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              peerIPv6Subnet = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              peerIPv6LinkLocal = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              myIPv4 = lib.mkOption {
                type = lib.types.str;
                default = LT.this.dn42.IPv4;
              };
              myIPv6 = lib.mkOption {
                type = lib.types.str;
                default = LT.this.dn42.IPv6;
              };
              myIPv6Subnet = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              myIPv6LinkLocal = lib.mkOption {
                type = lib.types.str;
                default = "fe80::2547";
              };
              IPv6SubnetMask = lib.mkOption {
                type = lib.types.int;
                default = 0;
              };
            };
          };
        };
      };
    });
    default = { };
  };

  config.networking.wireguard.enable = true;
  config.networking.wireguard.interfaces =
    let
      cfgToWg = n: v:
        let
          interfaceName = "${v.peering.network}-${n}";
        in
        lib.nameValuePair interfaceName ({
          allowedIPsAsRoutes = false;
          listenPort = v.tunnel.localPort;
          peers = [{
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            dynamicEndpointRefreshSeconds = 3600;
            endpoint = lib.mkIf (v.tunnel.remoteAddress != null) "${v.tunnel.remoteAddress}:${builtins.toString v.tunnel.remotePort}";
            publicKey = v.tunnel.wireguardPubkey;
            presharedKeyFile = v.tunnel.wireguardPresharedKeyFile;
          }];
          postSetup = setupAddressing interfaceName v;
          privateKeyFile = config.age.secrets.wg-priv.path;
        });
    in
    lib.mapAttrs' cfgToWg (filterType "wireguard" config.services.dn42);

  config.services.openvpn.servers =
    let
      cfgToOpenVPN = n: v:
        let
          interfaceName = "${v.peering.network}-${n}";
        in
        lib.nameValuePair interfaceName ({
          config = ''
            proto         udp
            mode          p2p
            remote        ${v.tunnel.remoteAddress}
            rport         ${builtins.toString v.tunnel.remotePort}
            local         ${LT.this.public.IPv4}
            lport         ${builtins.toString v.tunnel.localPort}
            dev-type      tun
            resolv-retry  infinite
            dev           ${interfaceName}
            comp-lzo
            persist-key
            persist-tun
            cipher        aes-256-cbc
            secret        ${v.tunnel.openvpnStaticKeyPath}
          '';
          up = setupAddressing interfaceName v;
        });
    in
    lib.mapAttrs' cfgToOpenVPN (filterType "openvpn" config.services.dn42);

  config.systemd.services =
    let
      cfgToGRE = n: v:
        let
          interfaceName = "${v.peering.network}-${n}";
        in
        lib.nameValuePair "gre-${interfaceName}" {
          serviceConfig.Type = "oneshot";
          serviceConfig.RemainAfterExit = true;
          wantedBy = [ "multi-user.target" ];
          unitConfig = {
            After = "network.target";
          };
          script = ''
            ${pkgs.iproute2}/bin/ip tunnel add ${interfaceName} mode gre remote ${v.tunnel.remoteAddress} local ${LT.this.public.IPv4} ttl 255
            ${pkgs.iproute2}/bin/ip link set ${interfaceName} up
          '' + lib.optionalString (v.tunnel.mtu != null) ''
            ${pkgs.iproute2}/bin/ip link set ${interfaceName} mtu ${builtins.toString v.tunnel.mtu}
          '' + setupAddressing interfaceName v;
          preStop = ''
            ${pkgs.iproute2}/bin/ip tunnel del ${interfaceName}
          '';
        }
      ;
    in
    (lib.mapAttrs' cfgToGRE (filterType "gre" config.services.dn42));
}
