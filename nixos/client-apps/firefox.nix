{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;

  mkValue = v: {
    Value = v;
    Status = "locked";
  };
in
{
  # https://github.com/mozilla/policy-templates/blob/master/README.md
  environment.etc."firefox/policies/policies.json".text = builtins.toJSON {
    policies = {
      DisableAppUpdate = true;
      DisabledCiphers = {
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256" = false;
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256" = false;
        "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256" = false;
        "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256" = false;
        "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384" = false;
        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384" = false;
        "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA" = true;
        "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA" = true;
        "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA" = true;
        "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA" = true;
        "TLS_DHE_RSA_WITH_AES_128_CBC_SHA" = true;
        "TLS_DHE_RSA_WITH_AES_256_CBC_SHA" = true;
        "TLS_RSA_WITH_AES_128_GCM_SHA256" = true;
        "TLS_RSA_WITH_AES_256_GCM_SHA384" = true;
        "TLS_RSA_WITH_AES_128_CBC_SHA" = true;
        "TLS_RSA_WITH_AES_256_CBC_SHA" = true;
        "TLS_RSA_WITH_3DES_EDE_CBC_SHA" = true;
      };
      DisablePocket = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisableTelemetry = true;
      DisplayMenuBar = "never";
      DNSOverHTTPS = {
        Enabled = false;
        Locked = true;
      };
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
