{
  pkgs,
  LT,
  config,
  ...
}:
{
  stylix = {
    enable = true;
    enableReleaseChecks = false;

    image = ../../helpers/wallpaper/wallpaper.jpg;
    colorGeneration.scheme = "vibrant";
    colorGeneration.polarity = "dark";

    autoEnable = LT.this.hasTag LT.tags.client;
    targets = {
      console.enable = true;
      # Kmscon uses removed options
      kmscon.enable = false;
    };

    cursor = {
      package = pkgs.nur-xddxdd.sam-toki-mouse-cursors;
      name = "STMCS_601_Genshin_Furina";
      size = 32;
    };

    fonts = {
      serif = {
        package = pkgs.nerd-fonts.noto;
        name = "Source Han Serif";
      };

      sansSerif = {
        package = pkgs.nerd-fonts.ubuntu;
        name = "Ubuntu";
      };

      monospace = {
        package = pkgs.nerd-fonts.ubuntu-mono;
        name = "Ubuntu Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji-blob-bin;
        name = "Blobmoji";
      };

      sizes = {
        applications = 10;
        desktop = 10;
        popups = 10;
        terminal = 12;
      };
    };

    override =
      let
        prev = config.stylix.base16.mkSchemeAttrs config.stylix.base16Scheme;
      in
      {
        base01 = prev.base00;
      };
  };
}
