{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  # https://chromeenterprise.google/policies/
  programs.chromium = {
    enable = true;
    extraOpts = {
      # Miscellaneous
      AssistantWebEnabled = false;
      EnableMediaRouter = false;
      AccessibilityImageLabelsEnabled = false;
      AdsSettingForIntrusiveAdsSites = 2;
      AdvancedProtectionAllowed = true;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      AutoplayAllowed = false;
      BackgroundModeEnabled = false;
      BookmarkBarEnabled = false;
      BrowserLabsEnabled = false;
      BrowserNetworkTimeQueriesEnabled = false;
      BuiltInDnsClientEnabled = false;
      ClearBrowsingDataOnExitList = [
        "browsing_history"
        "download_history"
        "cached_images_and_files"
        "password_signin"
        "autofill"
        "site_settings"
      ];
      ClickToCallEnabled = false;
      DefaultBrowserSettingEnabled = false;
      EncryptedClientHelloEnabled = false;
      HighEfficiencyModeEnabled = false;
      ImportAutofillFormData = false;
      ImportBookmarks = false;
      ImportHistory = false;
      ImportHomepage = false;
      ImportSavedPasswords = false;
      ImportSearchEngine = false;
      InsecureFormsWarningsEnabled = true;
      LensRegionSearchEnabled = false;
      MediaRecommendationsEnabled = false;
      MetricsReportingEnabled = false;
      NetworkPredictionOptions = 2;
      PaymentMethodQueryEnabled = false;
      PromotionalTabsEnabled = false;
      SearchSuggestEnabled = true;
      ShoppingListEnabled = false;
      ShowFullUrlsInAddressBar = true;
      SideSearchEnabled = false;
      SitePerProcess = true;
      SpellCheckServiceEnabled = false;
      SpellcheckEnabled = false;
      TranslateEnabled = true;

      # Password manager
      PasswordManagerEnabled = false;

      # Printing
      CloudPrintProxyEnabled = false;

      # Startup, Home page and New Tab page
      HomepageLocation = "chrome://new-tab-page";
      ShowHomeButton = true;
    };
  };

  environment.systemPackages = with pkgs; [ google-chrome ];
}
