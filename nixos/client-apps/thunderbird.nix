{ pkgs, lib, ... }:
let
  mkValue = v: {
    Value = v;
    Status = "locked";
  };
in
{
  # https://github.com/thundernest/policy-templates/tree/master/templates/central
  environment.etc."thunderbird/policies/policies.json".text = builtins.toJSON {
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DNSOverHTTPS = {
        Enabled = false;
        Locked = true;
      };
      NetworkPrediction = false;
      OfferToSaveLogins = true;
      PasswordManagerEnabled = true;
      # Managed here rather than via programs.thunderbird.languagePacks, which
      # needs a package supporting `override` and thunderbird-bin does not.
      RequestedLocales = "zh-CN,en-US";
      ExtensionSettings = {
        "langpack-zh-CN@thunderbird.mozilla.org" = {
          installation_mode = "normal_installed";
          install_url = "https://releases.mozilla.org/pub/thunderbird/releases/${pkgs.thunderbird-bin.version}/linux-x86_64/xpi/zh-CN.xpi";
        };
      };
      Preferences = lib.mapAttrs (k: mkValue) {
        "gfx.webrender.all" = true;
        "gfx.webrender.compositor.force-enabled" = true;
        "gfx.x11-egl.force-enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "places.history.enabled" = false;
        "security.insecure_connection_text.enabled" = true;
        "security.insecure_connection_text.pbmode.enabled" = true;
        "security.osclientcerts.autoload" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [ thunderbird-bin ];
}
