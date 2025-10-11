{ pkgs, ... }:
{
  home.packages = [ pkgs.yt-dlp ];
  xdg.configFile."yt-dlp/config".text = ''
    --cookies-from-browser firefox
    --concurrent-fragments 5
    --retries infinite
    --format "bv+ba/b"
  '';
}
