{ pkgs, config, options, ... }:

let
  myASN = 4242422547;
  myASNAbbr = 2547;

  LT = import ../../helpers {  inherit config pkgs; };
  filterType = type: pkgs.lib.filterAttrs (n: v: v.tunnel.type == type);

  setupAddressing = interfaceName: v: ''
    ${pkgs.iproute2}/bin/ip addr add ${v.addressing.myIPv6LinkLocal}/10 dev ${interfaceName}
  '' + pkgs.lib.optionalString (v.addressing.peerIPv4 != null) ''
    ${pkgs.iproute2}/bin/ip addr add ${v.addressing.myIPv4} peer ${v.addressing.peerIPv4} dev ${interfaceName}
  '' + pkgs.lib.optionalString (v.addressing.peerIPv6 != null) ''
    ${pkgs.iproute2}/bin/ip addr add ${v.addressing.myIPv6} peer ${v.addressing.peerIPv6} dev ${interfaceName}
    ${pkgs.iproute2}/bin/ip route add ${v.addressing.peerIPv6}/128 src ${v.addressing.myIPv6} dev ${interfaceName}
  '' + pkgs.lib.optionalString (v.addressing.peerIPv6 == null) ''
    ${pkgs.iproute2}/bin/ip addr add ${v.addressing.myIPv6}/128 dev ${interfaceName}
  '' + pkgs.lib.optionalString (v.addressing.myIPv6Subnet != null) ''
    ${pkgs.iproute2}/bin/ip addr add ${v.addressing.myIPv6Subnet}/${builtins.toString v.addressing.IPv6SubnetMask} dev ${interfaceName}
  '' + ''
    ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.${interfaceName}.autoconf=0
    ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.${interfaceName}.accept_ra=0
    ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.${interfaceName}.addr_gen_mode=1
  '';
in
{
  config.age.secrets.wg-priv.file = ../../secrets/wg-priv + "/${config.networking.hostName}.age";

  options.services.dn42 = pkgs.lib.mkOption {
    type = pkgs.lib.types.attrsOf (pkgs.lib.types.submodule {
      options = {
        # Basic configuration
        remoteASN = pkgs.lib.mkOption {
          type = pkgs.lib.types.int;
          default = 0;
        };
        latencyMs = pkgs.lib.mkOption {
          type = pkgs.lib.types.int;
          default = 0;
        };
        badRouting = pkgs.lib.mkOption {
          type = pkgs.lib.types.bool;
          default = false;
        };

        # Peering (BGP) configuration
        peering = pkgs.lib.mkOption {
          default = {};
          type = pkgs.lib.types.submodule {
            options = {
              network = pkgs.lib.mkOption {
                type = pkgs.lib.types.enum [ "dn42" "neo" ];
                default = "dn42";
              };
              mpbgp = pkgs.lib.mkOption {
                type = pkgs.lib.types.bool;
                default = false;
              };
            };
          };
        };

        # Tunnel configuration
        tunnel = pkgs.lib.mkOption {
          default = {};
          type = pkgs.lib.types.submodule {
            options = {
              type = pkgs.lib.mkOption {
                type = pkgs.lib.types.enum [ "openvpn" "wireguard" "gre" ];
                default = "gre";
              };
              localPort = pkgs.lib.mkOption {
                type = pkgs.lib.types.int;
                default = 0;
              };
              remotePort = pkgs.lib.mkOption {
                type = pkgs.lib.types.int;
                default = 20000 + myASNAbbr;
              };
              remoteAddress = pkgs.lib.mkOption {
                type = pkgs.lib.types.nullOr pkgs.lib.types.str;
                default = null;
              };
              wireguardPubkey = pkgs.lib.mkOption {
                type = pkgs.lib.types.nullOr pkgs.lib.types.str;
                default = null;
              };
              openvpnStaticKeyPath = pkgs.lib.mkOption {
                type = pkgs.lib.types.nullOr pkgs.lib.types.str;
                default = null;
              };
              mtu = pkgs.lib.mkOption {
                type = pkgs.lib.types.nullOr pkgs.lib.types.int;
                default = null;
              };
            };
          };
        };

        # IP address inside tunnel
        addressing = pkgs.lib.mkOption {
          default = {};
          type = pkgs.lib.types.submodule {
            options = {
              peerIPv4 = pkgs.lib.mkOption {
                type = pkgs.lib.types.nullOr pkgs.lib.types.str;
                default = null;
              };
              peerIPv6 = pkgs.lib.mkOption {
                type = pkgs.lib.types.nullOr pkgs.lib.types.str;
                default = null;
              };
              peerIPv6Subnet = pkgs.lib.mkOption {
                type = pkgs.lib.types.nullOr pkgs.lib.types.str;
                default = null;
              };
              peerIPv6LinkLocal = pkgs.lib.mkOption {
                type = pkgs.lib.types.nullOr pkgs.lib.types.str;
                default = null;
              };
              myIPv4 = pkgs.lib.mkOption {
                type = pkgs.lib.types.str;
                default = LT.this.dn42.IPv4;
              };
              myIPv6 = pkgs.lib.mkOption {
                type = pkgs.lib.types.str;
                default = LT.this.dn42.IPv6;
              };
              myIPv6Subnet = pkgs.lib.mkOption {
                type = pkgs.lib.types.nullOr pkgs.lib.types.str;
                default = null;
              };
              myIPv6LinkLocal = pkgs.lib.mkOption {
                type = pkgs.lib.types.str;
                default = "fe80::2547";
              };
              IPv6SubnetMask = pkgs.lib.mkOption {
                type = pkgs.lib.types.int;
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

  config.networking.wg-quick.interfaces =
    let
      cfgToWgQuick = n: v:
        let
          interfaceName = "${v.peering.network}-${n}";
        in
        pkgs.lib.nameValuePair interfaceName ({
          listenPort = v.tunnel.localPort;
          mtu = v.tunnel.mtu;
          peers = [{
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = pkgs.lib.mkIf (v.tunnel.remoteAddress != null) "${v.tunnel.remoteAddress}:${builtins.toString v.tunnel.remotePort}";
            publicKey = v.tunnel.wireguardPubkey;
          }];
          postUp = setupAddressing interfaceName v;
          privateKeyFile = config.age.secrets.wg-priv.path;
          table = "off";
        });
    in
    pkgs.lib.mapAttrs' cfgToWgQuick (filterType "wireguard" config.services.dn42);

  config.services.openvpn.servers =
    let
      cfgToOpenVPN = n: v:
        let
          interfaceName = "${v.peering.network}-${n}";
        in
        pkgs.lib.nameValuePair interfaceName ({
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
    pkgs.lib.mapAttrs' cfgToOpenVPN (filterType "openvpn" config.services.dn42);

  config.systemd.services =
    let
      cfgToGRE = n: v:
        let
          interfaceName = "${v.peering.network}-${n}";
        in
        pkgs.lib.nameValuePair "gre-${interfaceName}" {
          serviceConfig.Type = "oneshot";
          serviceConfig.RemainAfterExit = true;
          wantedBy = [ "multi-user.target" ];
          unitConfig = {
            After = "network.target";
          };
          script = ''
            ${pkgs.iproute2}/bin/ip tunnel add ${interfaceName} mode gre remote ${v.tunnel.remoteAddress} local ${LT.this.public.IPv4} ttl 255
            ${pkgs.iproute2}/bin/ip link set ${interfaceName} up
          '' + pkgs.lib.optionalString (v.tunnel.mtu != null) ''
            ${pkgs.iproute2}/bin/ip link set ${interfaceName} mtu ${builtins.toString v.tunnel.mtu}
          '' + setupAddressing interfaceName v;
          preStop = ''
            ${pkgs.iproute2}/bin/ip tunnel del ${interfaceName}
          '';
        }
      ;
    in
    pkgs.lib.mapAttrs' cfgToGRE (filterType "gre" config.services.dn42);
}
