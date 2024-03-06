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
    image = "ghcr.io/suwayomi/tachidesk:preview";
    environment = {
      TZ = config.time.timeZone;
      WEB_UI_CHANNEL = "preview";
      AUTO_DOWNLOAD_CHAPTERS = "true";
      UPDATE_EXCLUDE_UNREAD = "false";
      UPDATE_EXCLUDE_STARTED = "false";
      UPDATE_EXCLUDE_COMPLETED = "false";
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

  lantian.nginxVhosts."tachidesk.xuyh0120.win" = {
    locations = {
      "/" = {
        enableBasicAuth = true;
        proxyPass = "http://127.0.0.1:${LT.portStr.Tachidesk}";
      };
    };

    sslCertificate = "xuyh0120.win_ecc";
    noIndex.enable = true;
  };
}
