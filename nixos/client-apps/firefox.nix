{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    bilisponsorblock
    bitwarden
    bypass-paywalls-clean
    clearurls
    darkreader
    dearrow
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
    privacy-pass
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

  loadBetterfox =
    path:
    let
      autogen = lib.importJSON (inputs.betterfox-nix + "/autogen/firefox/main.json");
      settings = lib.attrByPath (lib.splitString "." "${path}.settings") null autogen;
    in
    builtins.listToAttrs (builtins.filter (v: v.enabled) settings);

  betterfoxConfig = builtins.foldl' (a: b: a // loadBetterfox b) { } [
    "fastfox.general"
    "fastfox.gfx"
    "fastfox.disk-cache"
    "fastfox.media-cache"
    "fastfox.image-cache"
    "fastfox.network"
    "fastfox.speculative-loading"
    "fastfox.experimental"
    "securefox.ocsp-and-certs-with-hpkp"
    "securefox.ssl-with-tls"
    "securefox.disk-avoidance"
    "securefox.https-first-policy"
    "securefox.mixed-content-plus-cross-site"
    "securefox.headers-with-referers"
    "securefox.safe-browsing"
    "securefox.telemetry"
    "securefox.experiments"
    "securefox.crash-reports"
    "peskyfox.mozilla-ui"
    "peskyfox.url-bar"
    "peskyfox.new-tab-page"
    "peskyfox.pocket"
    "peskyfox.downloads"
  ];
in
{
  environment.systemPackages = [
    (lib.hiPrio pkgs.nur-xddxdd.lantianCustomized.firefox-icon-mikozilla-fireyae)
  ];

  environment.variables = {
    MOZ_X11_EGL = "1";
    MOZ_USE_XINPUT2 = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };

  # https://github.com/mozilla/policy-templates/blob/master/README.md
  programs.firefox = {
    enable = true;

    # package = inputs.firefox-nightly.packages."${pkgs.system}".firefox-nightly-bin;

    languagePacks = [ "zh-CN" ];
    policies = {
      DisableAppUpdate = true;
      DisabledCiphers = {
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256" = false;
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256" = false;
        "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256" = false;
        "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256" = false;
        "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384" = false;
        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384" = false;

        # Reenabled for breaking many sites
        "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA" = false;
        "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA" = false;
        "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA" = false;
        "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA" = false;
        "TLS_DHE_RSA_WITH_AES_128_CBC_SHA" = false;
        "TLS_DHE_RSA_WITH_AES_256_CBC_SHA" = false;
        "TLS_RSA_WITH_AES_128_GCM_SHA256" = false;
        "TLS_RSA_WITH_AES_256_GCM_SHA384" = false;
        "TLS_RSA_WITH_AES_128_CBC_SHA" = false;
        "TLS_RSA_WITH_AES_256_CBC_SHA" = false;
        "TLS_RSA_WITH_3DES_EDE_CBC_SHA" = false;
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
        # URL = "https://homepage.lt-home-vm.xuyh0120.win";
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
      SanitizeOnShutdown = {
        Cache = true;
        Downloads = true;
        FormData = true;
        History = true;
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

      ExtensionSettings = builtins.listToAttrs (
        builtins.map (
          e:
          lib.nameValuePair e.addonId {
            installation_mode = "force_installed";
            install_url = "file://${e.src}";
            updates_disabled = true;
          }
        ) extensions
      );
    };
    preferences = betterfoxConfig // {
      "browser.aboutConfig.showWarning" = false;
      "gfx.webrender.all" = true;
      "gfx.webrender.compositor.force-enabled" = true;
      "gfx.x11-egl.force-enabled" = true;
      "media.av1.enabled" = true;
      "media.ffmpeg.vaapi.enabled" = true;
      "media.hardware-video-decoding.force-enabled" = true;
      "media.hls.enabled" = true;
      "media.videocontrols.picture-in-picture.enabled" = false;
      "security.insecure_connection_text.enabled" = true;
      "security.insecure_connection_text.pbmode.enabled" = true;
      "security.osclientcerts.autoload" = true;
      "geo.provider.network.url" = "https://api.beacondb.net/v1/geolocate";
      "geo.provider.use_geoclue" = config.services.geoclue2.enable;
    };
    preferencesStatus = "locked";
  };
}
