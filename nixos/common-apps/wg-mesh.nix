{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  wg-pubkey = import (pkgs.secrets + "/wg-pubkey.nix");
in
{
  networking.wireguard.interfaces = lib.mapAttrs'
    (n: v:
      let
        interfaceName = "ltmesh-${builtins.toString v.index}";
      in
      lib.nameValuePair interfaceName {
        # ips = [ "169.254.0.${builtins.toString LT.this.index}/24" "fe80::${builtins.toString LT.this.index}/64" ];
        listenPort = LT.port.WGMesh.Start + v.index;
        privateKeyFile = config.age.secrets.wg-priv.path;
        allowedIPsAsRoutes = false;
        peers = [{
          publicKey = wg-pubkey."${n}";
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          endpoint = "${n}.lantian.pub:${builtins.toString (LT.port.WGMesh.Start + LT.this.index)}";
          persistentKeepalive = 25;
        }];
        postSetup = ''
          ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.${interfaceName}.autoconf=0
          ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.${interfaceName}.accept_ra=0
          ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.${interfaceName}.addr_gen_mode=1
          ${pkgs.iproute2}/bin/ip link set ${interfaceName} mtu 1400
          ${pkgs.iproute2}/bin/ip addr add 169.254.0.${builtins.toString LT.this.index} peer 169.254.0.${builtins.toString v.index} dev ${interfaceName}
          ${pkgs.iproute2}/bin/ip addr add fe80::${builtins.toString LT.this.index}/64 dev ${interfaceName}
        '';
      })
    LT.otherHosts;
}
