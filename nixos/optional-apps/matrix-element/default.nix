{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  elementConfig = builtins.toJSON {
    default_server_config = builtins.fromJSON LT.constants.matrixWellKnown.client;
    disable_custom_urls = true;
    disable_guests = true;
    disable_login_language_selector = false;
    disable_3pid_login = true;
    default_country_code = "US";
    show_labs_settings = true;
    default_federate = true;
    default_theme = "dark";
    room_directory.servers = [
      "matrix.org"
      "nixos.org"
      "hackint.org"
      "lantian.pub"
    ];
    branding.welcome_background_url = import ./background.nix;
    embedded_pages.login_for_welcome = true;
    setting_defaults = {
      "UIFeature.feedback" = false;
      "UIFeature.registration" = false;
      "UIFeature.passwordReset" = false;
      "UIFeature.deactivate" = false;
      "UIFeature.TimelineEnableRelativeDates" = false;
    };
  };

  elementConfigFile = pkgs.runCommandNoCC "element-config.json" { } ''
    ${pkgs.jq}/bin/jq -s '.[0] * $conf' "${pkgs.element-web}/config.json" --argjson "conf" '${elementConfig}' > "$out"
  '';
in
{
  lantian.nginxVhosts."element.lantian.pub" = {
    listenHTTP.enable = true;
    root = builtins.toString pkgs.element-web;
    locations = {
      "/" = {
        index = "index.html index.htm";
        tryFiles = "$uri $uri/ =404";
      };
      "= /config.json".alias = elementConfigFile;
    };

    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
  };
}
