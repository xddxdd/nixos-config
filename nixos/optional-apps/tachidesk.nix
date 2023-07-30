{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  virtualisation.oci-containers.containers.tachidesk = {
    extraOptions = ["--pull" "always"];
    image = "ghcr.io/suwayomi/tachidesk:latest";
    environment = {
      TZ = config.time.timeZone;
    };
    ports = [
      "127.0.0.1:${LT.portStr.Tachidesk}:4567"
    ];
    volumes = [
      "/var/lib/tachidesk:/home/suwayomi/.local/share/Tachidesk"
    ];
  };

  systemd.tmpfiles.rules = [
    # Tachidesk container uses pid/gid 1000/1000
    "d /var/lib/tachidesk 755 1000 1000"
  ];

  services.nginx.virtualHosts."tachidesk.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf {} {
      "/".extraConfig =
        LT.nginx.locationBasicAuthConf
        + ''
          proxy_pass http://127.0.0.1:${LT.portStr.Tachidesk};
        ''
        + LT.nginx.locationProxyConf;
    };
    extraConfig =
      LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };
}
