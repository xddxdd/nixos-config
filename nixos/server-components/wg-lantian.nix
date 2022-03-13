{ pkgs, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };

  wg-pubkey = import (pkgs.secrets + "/config/wg-pubkey.nix");
in
{
  networking.wireguard.interfaces.wg-lantian = {
    ips = [ "192.0.2.1/24" "fc00::1/64" ];
    listenPort = 22547;
    privateKeyFile = config.age.secrets.wg-priv.path;
    peers = pkgs.lib.mapAttrsToList
      (n: v: {
        publicKey = wg-pubkey."${n}";
        allowedIPs = [
          "192.0.2.${builtins.toString v.index}/32"
          "fc00::${builtins.toString v.index}/128"
        ];
      })
      (pkgs.lib.filterAttrs (n: v: v.role != LT.roles.server) LT.hosts);
  };
}
