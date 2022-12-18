{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  age.secrets.wg-cf-warp = {
    file = inputs.secrets + "/wgcf/${config.networking.hostName}.conf.age";
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
      exec wg-quick up ${config.age.secrets.wg-cf-warp.path}
    '';

    preStop = ''
      exec wg-quick down ${config.age.secrets.wg-cf-warp.path}
    '';
  };
}
