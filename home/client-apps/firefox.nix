{
  pkgs,
  lib,
  inputs,
  osConfig,
  ...
}:
let
  args = {
    enable = true;
    package = null; # Already installed system wide
    profiles.lantian = {
      extensions = {
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bilisponsorblock
          bitwarden
          clearurls
          darkreader
          downthemall
          enhancer-for-youtube
          fastforwardteam
          flagfox
          i-dont-care-about-cookies
          ipfs-companion
          immersive-translate
          lovely-forks
          multi-account-containers
          noscript
          pakkujs
          pay-by-privacy
          plasma-integration
          protondb-for-steam
          return-youtube-dislikes
          rsshub-radar
          sponsorblock
          steam-database
          tab-reloader
          tampermonkey
          to-google-translate
          ublacklist
          ublock-origin
          wappalyzer
          wayback-machine
        ];
        force = true;
      };

      search = {
        default = "google";
        force = true;
      };

      settings = {
        "browser.aboutConfig.showWarning" = false;
        "gfx.webrender.all" = true;
        # FIXME: enabling causes graphic glitches
        "gfx.webrender.compositor.force-enabled" = false;
        "gfx.x11-egl.force-enabled" = true;
        "image.avif.enabled" = true;
        "image.jxl.enabled" = true;
        "media.av1.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.hls.enabled" = true;
        "media.videocontrols.picture-in-picture.enabled" = false;
        "security.insecure_connection_text.enabled" = true;
        "security.insecure_connection_text.pbmode.enabled" = true;
        "security.osclientcerts.autoload" = true;
        "geo.provider.network.url" = lib.mkForce "https://api.beacondb.net/v1/geolocate";
        "geo.provider.use_geoclue" = osConfig.services.geoclue2.enable;
        "browser.ml.chat.provider" = "https://ai.xuyh0120.win";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;

        # Make home-manager extension config work
        "extensions.webextensions.ExtensionStorageIDB.enabled" = false;

        # Vertical tabs
        "sidebar.verticalTabs" = true;
        "browser.tabs.groups.enabled" = true;
        "browser.tabs.groups.smart.enabled" = true;
        "browser.tabs.unloadTabInContextMenu" = true;

        # Auto enable installed extensions
        "extensions.autoDisableScopes" = 0;
      };

      userChrome = ''
        .titlebar-spacer {
          display: none !important;
        }
      '';
    };
  };

  betterfoxArgs = {
    enable = true;
    fastfox.enable = true;
    securefox.enable = true;
    peskyfox.enable = true;
  };
in
{
  imports = [ inputs.betterfox-nix.homeManagerModules.betterfox ];

  programs.firefox = lib.recursiveUpdate args {
    betterfox.enable = true;
    profiles.lantian.betterfox = betterfoxArgs;
  };
  programs.librewolf = lib.recursiveUpdate args {
    package = pkgs.librewolf;
    betterfox = {
      enable = true;
      settings = betterfoxArgs;
    };
  };
}
