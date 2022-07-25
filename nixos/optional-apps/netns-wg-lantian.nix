{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  netns = LT.netns {
    name = "wg-lantian";
    setupDefaultRoute = false;
  };

  wg-pubkey = import (pkgs.secrets + "/wg-pubkey.nix");
in
{
  age.secrets.wg-priv.file = pkgs.secrets + "/wg-priv/${config.networking.hostName}.age";

  environment.etc."netns/ns-wg-lantian/resolv.conf".text = ''
    nameserver 8.8.8.8
    options single-request edns0
  '';

  networking.wireguard.interfaces.wg-lantian = {
    ips = [
      "192.0.2.${builtins.toString LT.this.index}/24"
      "fc00::${builtins.toString LT.this.index}/64"
    ];
    listenPort = 22547;
    privateKeyFile = config.age.secrets.wg-priv.path;
    interfaceNamespace = "ns-wg-lantian";
    peers = [
      {
        endpoint = "${LT.hosts.buyvm.public.IPv4}:22547";
        publicKey = wg-pubkey.buyvm;
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        persistentKeepalive = 25;
      }
    ];
  };

  systemd.services = netns.setup // {
    "wireguard-wg-lantian" = netns.bindExisting // {
      # Don't override network namespace
      serviceConfig = { };
    };
  };
}
