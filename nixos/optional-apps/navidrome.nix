{
  config,
  pkgs,
  ...
}:
{
  services.navidrome = {
    enable = true;
    settings = {
      Address = "unix:/run/navidrome/navidrome.sock";
      BaseUrl = "https://navidrome.${config.networking.hostName}.xuyh0120.win";
      MusicFolder = "/mnt/storage/media/CloudMusic";
      DefaultLanguage = "zh-Hans";
      EnableGravatar = true;
      EnableStarRating = false;
      LastFM.Enabled = false;
      ListenBrainz.Enabled = false;
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
      Restart = "always";
      RestartSec = 5;
    };
  };

  lantian.nginxVhosts = {
    "navidrome.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://unix:/run/navidrome/navidrome.sock";
        };
      };

      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
      accessibleBy = "private";
    };
  };

  users.users.nginx.extraGroups = [ config.services.navidrome.group ];
}
