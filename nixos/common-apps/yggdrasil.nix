{ pkgs, config, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
in
{
  services.yggdrasil = {
    enable = true;
    group = "wheel";
    config = {
      Listen = [ "tls://[::]:${LT.portStr.Yggdrasil.Public}" ];

      MulticastInterfaces = [{
        Regex = "ltmesh";
        Beacon = true;
        Listen = true;
        Port = LT.port.Yggdrasil.Multicast;
      }];

      IfName = "yggdrasil";
      NodeInfoPrivacy = true;
    };
    persistentKeys = true;
  };

  systemd.services.yggdrasil.serviceConfig.ExecStart =
    pkgs.lib.mkForce "${config.services.yggdrasil.package}/bin/yggdrasil -loglevel error -logto syslog -useconffile /run/yggdrasil/yggdrasil.conf";
}
