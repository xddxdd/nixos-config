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
          fastforwardteam
          flagfox
          i-dont-care-about-cookies
          ipfs-companion
          kiss-translator
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
          tweaks-for-youtube
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
        # keep-sorted start
        "browser.aboutConfig.showWarning" = false;
        # AI Sidebar
        "browser.ml.chat.provider" = "https://ai.xuyh0120.win";
        "browser.tabs.groups.enabled" = true;
        "browser.tabs.groups.smart.enabled" = true;
        "browser.tabs.unloadTabInContextMenu" = true;
        "extensions.autoDisableScopes" = 0; # Auto enable installed extensions
        "extensions.webextensions.ExtensionStorageIDB.enabled" = false; # Make home-manager extension config work
        "geo.provider.network.url" = lib.mkForce "https://api.beacondb.net/v1/geolocate";
        "geo.provider.use_geoclue" = osConfig.services.geoclue2.enable;
        "gfx.wayland.hdr" = true;
        "gfx.webrender.all" = true;
        "gfx.webrender.compositor.force-enabled" = false; # FIXME: enabling causes graphic glitches
        "gfx.x11-egl.force-enabled" = true;
        "image.avif.enabled" = true;
        "image.jxl.enabled" = true;
        "media.av1.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.hevc.enabled" = true;
        "media.hls.enabled" = true;
        "media.videocontrols.picture-in-picture.enabled" = false;
        "security.insecure_connection_text.enabled" = true;
        "security.insecure_connection_text.pbmode.enabled" = true;
        "security.osclientcerts.autoload" = true;
        "sidebar.verticalTabs" = true;
        "svg.context-properties.content.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # keep-sorted end
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
  };
}
