{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  mkValue = v: {
    Value = v;
    Status = "locked";
  };
in
{
  environment.etc."firefox/policies/policies.json".text = builtins.toJSON {
    policies = {
      DisableAppUpdate = true;
      DisablePocket = true;
      DisableSetDesktopBackground = true;
      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      FirefoxHome = {
        Highlights = false;
        Locked = true;
        Pocket = false;
        Search = true;
        Snippets = false;
        SponsoredPocket = false;
        SponsoredTopSites = false;
        TopSites = false;
      };
      Homepage = {
        URL = "about:home";
        Locked = true;
        StartPage = "homepage";
      };
      NetworkPrediction = false;
      NewTabPage = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      PasswordManagerEnabled = false;
      Preferences = lib.mapAttrs (k: mkValue) {
        "browser.aboutConfig.showWarning" = false;
        "gfx.webrender.all" = true;
        "gfx.webrender.compositor.force-enabled" = true;
        "gfx.x11-egl.force-enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        # FFVPX must be disabled for VAAPI AV1 to work
        "media.ffvpx.enabled" = false;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.rdd-ffvpx.enabled" = false;
        "media.utility-ffvpx.enabled" = false;
        "security.insecure_connection_text.enabled" = true;
        "security.insecure_connection_text.pbmode.enabled" = true;
        "security.osclientcerts.autoload" = true;
      };
      SanitizeOnShutdown = {
        Cache = true;
        Downloads = true;
        FormData = true;
        History = true;
        Locked = true;
      };
      SearchBar = "unified";
      SearchSuggestEnabled = true;
      ShowHomeButton = false;
      SupportMenu = {
        Title = "Lan Tian @ Blog";
        URL = "https://lantian.pub";
        AccessKey = "S";
      };
      UserMessaging = {
        WhatsNew = false;
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
      };
      UseSystemPrintDialog = true;
    };
  };

  environment.systemPackages = with pkgs; [
    firefox
  ];
}
