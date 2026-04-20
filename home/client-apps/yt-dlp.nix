_: {
  programs.yt-dlp = {
    enable = true;
    settings = {
      cookies-from-browser = "firefox";
      concurrent-fragments = 5;
      retries = "infinite";
      format = "bv+ba/b";
    };
  };
}
