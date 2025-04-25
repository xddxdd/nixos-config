{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.navidrome = {
    enable = true;
    settings = {
      Address = "unix:/run/navidrome/navidrome.sock";
      BaseUrl = "https://navidrome.${config.networking.hostName}.xuyh0120.win";
      DefaultLanguage = "zh-Hans";
      EnableGravatar = true;
      EnableStarRating = false;
      Jukebox.AdminOnly = false;
      Jukebox.Enabled = true;
      LastFM.Enabled = false;
      ListenBrainz.Enabled = false;
      MusicFolder = "/mnt/storage/media/CloudMusic";
      RecentlyAddedByModTime = true;
      Scanner.Schedule = "0 * * * *";
      SearchFullString = true;
    };
  };

  systemd.services.navidrome = {
    path = [
      pkgs.ffmpeg
      pkgs.mpv
    ];
    serviceConfig = {
      PrivateDevices = lib.mkForce false;
      PrivateUsers = lib.mkForce false;
      RestrictAddressFamilies = lib.mkForce "";
    };
  };

  lantian.nginxVhosts = {
    "navidrome.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://unix:/run/navidrome/navidrome.sock";
        };
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
      accessibleBy = "private";
    };
  };

  users.users.navidrome.extraGroups = [
    "audio"
  ] ++ lib.optionals config.services.pipewire.systemWide [ "pipewire" ];
  users.users.nginx.extraGroups = [ config.services.navidrome.group ];
}
