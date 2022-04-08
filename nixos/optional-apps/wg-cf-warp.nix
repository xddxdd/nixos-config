{ config, pkgs, lib, ... }:

{
  age.secrets.wg-cf-warp = {
    file = pkgs.secrets + "/wgcf/${config.networking.hostName}.conf.age";
    name = "wg-cf-warp.conf";
  };
  systemd.services.wg-cf-warp = {
    description = "Cloudflare Warp";
    requires = [ "network-online.target" ];
    after = [ "network.target" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment.DEVICE = "wg-cf-warp";
    path = [ pkgs.kmod pkgs.wireguard-tools ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${lib.optionalString (!config.boot.isContainer) "modprobe wireguard"}
      wg-quick up ${config.age.secrets.wg-cf-warp.path}
    '';

    preStop = ''
      wg-quick down ${config.age.secrets.wg-cf-warp.path}
    '';
  };
}
