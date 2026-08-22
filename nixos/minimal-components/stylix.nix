{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  stylix = {
    enable = true;
    enableReleaseChecks = false;

    image = ../../helpers/wallpaper/wallpaper.jpg;
    polarity = "dark";
    palette = {
      generators.semantic = config.stylix.lib.generators.semantic.matugen {
        scheme = "vibrant";
        filter = "lanczos3";
      };
      mappingFunction = lib.flip lib.pipe [
        config.stylix.lib.mappings.semantic2base16
        (
          { polarity, palette }:
          {
            inherit polarity;
            palette = palette // {
              base16 = palette.base16 // {
                base01 = palette.base16.base00;
              };
            };
          }
        )
        config.stylix.lib.mappings.base162base24
      ];
    };

    autoEnable = LT.this.hasTag LT.tags.client;
    targets = {
      console.enable = true;
      # FIXME: workaround stylix bug
      qt.platform = lib.mkForce "kde";
      # Kmscon uses removed options
      kmscon.enable = false;
      # Regreet isn't updated in matugen fork
      regreet.enable = false;
    };

    cursor =
      if LT.this.hasTag LT.tags.client then
        {
          package = pkgs.nur-xddxdd.sam-toki-mouse-cursors;
          name = "STMC_6_1_Genshin_Furina";
          size = 32;
        }
      else
        null;

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
  };
}
