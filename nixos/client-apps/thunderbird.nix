{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  mkValue = v: {
    Value = v;
    Status = "locked";
  };
in {
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
      };
    };
  };

  environment.systemPackages = with pkgs; [
    thunderbird
  ];
}
