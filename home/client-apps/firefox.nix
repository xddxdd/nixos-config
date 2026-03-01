{
  pkgs,
  lib,
  inputs,
  osConfig,
  LT,
  ...
}:
let
  args = {
    enable = true;
    package = null; # Already installed system wide
    profiles.lantian = {
      extensions = {
        packages = with pkgs.firefox-addons; [
          # keep-sorted start
          awardwallet
          bilisponsorblock
          bitwarden-password-manager
          cardpointers-x
          clearurls
          darkreader
          dont-track-me-google1
          downthemall
          fastforwardteam
          flagfox
          i-dont-care-about-cookies
          ipfs-companion
          kiss-translator
          linux_do-scripts
          lovely-forks
          multi-account-containers
          noscript
          pakkujs
          pay-by-privacy
          phantom-app
          plasma-integration
          protondb-for-steam
          pt-depiler
          redirector
          return-youtube-dislikes
          rsshub-radar
          sponsorblock
          steam-database
          tab-reloader
          tampermonkey
          tweaks-for-youtube
          ublacklist
          ublock-origin
          wappalyzer
          # keep-sorted end
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
        "browser.tabs.groups.enabled" = false;
        "browser.tabs.groups.smart.enabled" = false;
        "browser.tabs.unloadTabInContextMenu" = true;
        "extensions.autoDisableScopes" = 0; # Auto enable installed extensions
        "extensions.update.enabled" = false;
        "extensions.webextensions.ExtensionStorageIDB.enabled" = false; # Make home-manager extension config work
        "font.size.monospace.x-western" = lib.mkForce 16;
        "font.size.variable.x-western" = lib.mkForce 16;
        "geo.provider.network.url" = lib.mkForce "https://api.beacondb.net/v1/geolocate";
        "geo.provider.use_geoclue" = osConfig.services.geoclue2.enable;
        "gfx.wayland.hdr" = false; # FIXME: causes crashes
        "gfx.wayland.hdr.force-enabled" = false; # FIXME: causes crashes
        "gfx.webrender.all" = true;
        "gfx.webrender.compositor.force-enabled" = false; # FIXME: causes crashes
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
      }
      // builtins.listToAttrs (
        builtins.map (suffix: lib.nameValuePair "browser.fixup.domainsuffixwhitelist.${suffix}" true) (
          lib.filter (s: !lib.hasInfix "." s) (lib.flatten (builtins.attrValues LT.constants.zones))
        )
      );
    };
  };
in
{
  imports = [ inputs.betterfox-nix.homeModules.betterfox ];

  programs.firefox = lib.recursiveUpdate args {
    package = null;
    betterfox = {
      enable = true;
      profiles.lantian.settings = {
        fastfox.enable = true;
        securefox.enable = true;
        peskyfox.enable = true;
        peskyfox.ai.enable = false;
      };
    };
  };
  programs.librewolf = lib.recursiveUpdate args {
    package = pkgs.librewolf;
  };
}
