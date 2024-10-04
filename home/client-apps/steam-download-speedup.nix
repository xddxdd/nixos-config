_: {
  # https://www.reddit.com/r/linux_gaming/comments/16e1l4h/slow_steam_downloads_try_this/
  xdg.dataFile."Steam/steam_dev.cfg".text = ''
    @nClientDownloadEnableHTTP2PlatformLinux 0
    @fDownloadRateImprovementToAddAnotherConnection 1.1
    @cMaxInitialDownloadSources 15
  '';
}
