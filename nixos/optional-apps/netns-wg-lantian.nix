{ pkgs, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };

  wg-pubkey = import (pkgs.secrets + "/config/wg-pubkey.nix");
in
{
  age.secrets.wg-priv.file = pkgs.secrets + "/wg-priv/${config.networking.hostName}.age";

  environment.etc."netns/ns-wg-lantian/resolv.conf".text = ''
    nameserver 8.8.8.8
    options edns0
  '';

  systemd.services."netns-instance-wg-lantian" =
    let
      name = "wg-lantian";
      ipbin = "${pkgs.iproute2}/bin/ip";
      ipns = "${ipbin} netns exec ns-${name} ${ipbin}";
      sysctl = "${ipbin} netns exec ns-${name} ${pkgs.procps}/bin/sysctl";
    in
    {
      wantedBy = [ "multi-user.target" "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        ExecStartPre = [
          "-${ipbin} netns delete ns-${name}"
        ];
        ExecStart = [
          # Setup namespace
          "${ipbin} netns add ns-${name}"
          "${ipns} link set lo up"
          # Disable auto generated IPv6 link local address
          "${sysctl} -w net.ipv6.conf.default.autoconf=0"
          "${sysctl} -w net.ipv6.conf.all.autoconf=0"
          "${sysctl} -w net.ipv6.conf.default.accept_ra=0"
          "${sysctl} -w net.ipv6.conf.all.accept_ra=0"
          "${sysctl} -w net.ipv6.conf.default.addr_gen_mode=1"
          "${sysctl} -w net.ipv6.conf.all.addr_gen_mode=1"
        ];
        ExecStopPost = [
          "${ipbin} netns delete ns-${name}"
        ];
      };
    };

  networking.wireguard.interfaces.wg-lantian = {
    ips = [
      "192.0.2.${builtins.toString LT.this.index}/24"
      "fc00::${builtins.toString LT.this.index}/64"
    ];
    listenPort = 22547;
    privateKeyFile = config.age.secrets.wg-priv.path;
    interfaceNamespace = "ns-wg-lantian";
    peers = [
      ({
        endpoint = "v4.buyvm.lantian.pub:22547";
        publicKey = wg-pubkey.buyvm;
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        persistentKeepalive = 25;
      })
    ];
  };
}
