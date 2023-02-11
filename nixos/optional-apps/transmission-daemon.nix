{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  services.transmission = {
    enable = true;
    user = "lantian";
    group = "users";
    downloadDirPermissions = "775";
    settings = {
      cache-size-mb = 64;
      download-dir = lib.mkDefault "/nix/persistent/media/Transmission";
      download-queue-enabled = false;
      encryption = 2;
      idle-seeding-limit-enabled = false;
      incomplete-dir-enabled = false;
      peer-limit-global = 10000;
      peer-limit-per-torrent = 10000;
      peer-port = LT.port.WGLanTian.ForwardStart + (LT.this.index - 1) * 10 + 9;
      peer-socket-tos = "lowcost";
      queue-stalled-enabled = false;
      rename-partial-files = true;
      rpc-bind-address = LT.this.ltnet.IPv4;
      rpc-host-whitelist-enabled = false;
      rpc-port = LT.port.Transmission;
      rpc-whitelist-enabled = false;
      seed-queue-enabled = false;
    };
  };

  services.nginx.virtualHosts = {
    "transmission.${config.networking.hostName}.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { } {
        "/".extraConfig = LT.nginx.locationOauthConf + ''
          proxy_pass http://${LT.this.ltnet.IPv4}:${LT.portStr.Transmission};
        '' + LT.nginx.locationProxyConf;
        "/transmission/web".alias = "${pkgs.transmission}/share/transmission/web";
      };
      extraConfig = LT.nginx.makeSSL "${config.networking.hostName}.xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
    "transmission.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf { } {
        "/".extraConfig = LT.nginx.locationOauthConf + ''
          proxy_pass http://${LT.this.ltnet.IPv4}:${LT.portStr.Transmission};
        '' + LT.nginx.locationProxyConf;
        "/transmission/web".alias = "${pkgs.transmission}/share/transmission/web";
      };
      extraConfig = LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost;
    };
  };
}
