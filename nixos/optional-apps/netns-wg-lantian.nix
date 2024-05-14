{
  LT,
  config,
  inputs,
  ...
}:
let
  netns = config.lantian.netns.wg-lantian;

  wg-pubkey = import (inputs.secrets + "/wg-pubkey.nix");
in
{
  age.secrets.wg-priv.file = inputs.secrets + "/wg-priv/${config.networking.hostName}.age";

  environment.etc."netns/wg-lantian/resolv.conf".text = ''
    nameserver 8.8.8.8
    options single-request edns0
  '';

  lantian.netns.wg-lantian = {
    ipSuffix = "192";
    enableDefaultRoute = false;
  };

  networking.wireguard.interfaces.wg-lantian = {
    ips = [
      "192.0.2.${builtins.toString LT.this.index}/24"
      "fc00::${builtins.toString LT.this.index}/64"
    ];
    listenPort = 22547;
    privateKeyFile = config.age.secrets.wg-priv.path;
    interfaceNamespace = "wg-lantian";
    peers = [
      {
        endpoint = "${LT.hosts.buyvm.public.IPv4}:22547";
        publicKey = wg-pubkey.buyvm;
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        persistentKeepalive = 25;
      }
    ];
  };

  systemd.services = {
    "wireguard-wg-lantian" = netns.bindExisting // {
      # Don't override network namespace
      serviceConfig = { };
    };
  };
}
