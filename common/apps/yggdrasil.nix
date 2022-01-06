{ pkgs, config, ... }:

{
  services.yggdrasil = {
    enable = true;
    group = "wheel";
    config = {
      Listen = [ "tls://[::]:13058" ];

      MulticastInterfaces = [{
        Regex = "ltmesh";
        Beacon = true;
        Listen = true;
        Port = 13059;
      }];

      IfName = "yggdrasil";
      NodeInfoPrivacy = true;
    };
    persistentKeys = true;
  };

  systemd.services.yggdrasil.serviceConfig.ExecStart =
    pkgs.lib.mkForce "${config.services.yggdrasil.package}/bin/yggdrasil -loglevel error -logto syslog -useconffile /run/yggdrasil/yggdrasil.conf";
}
