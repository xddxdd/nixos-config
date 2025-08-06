{
  pkgs,
  lib,
  LT,
  ...
}:
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

  elementConfigPath = LT.nginx.compressStaticAssets (
    pkgs.stdenvNoCC.mkDerivation {
      name = "element-config";
      dontUnpack = true;
      postInstall = ''
        mkdir -p $out
        ${pkgs.jq}/bin/jq -s -c '.[0] * $conf' "${pkgs.element-web}/config.json" --argjson "conf" '${elementConfig}' > "$out/config.json"
      '';
    }
  );
in
lib.mkIf (!(LT.this.hasTag LT.tags.low-disk)) {
  networking.hosts."127.0.0.1" = [ "element.lantian.pub" ];

  lantian.nginxVhosts."element.lantian.pub" = {
    listenHTTP.enable = true;
    root = builtins.toString (LT.nginx.compressStaticAssets pkgs.element-web);
    locations = {
      "/" = {
        index = "index.html index.htm";
        tryFiles = "$uri $uri/ =404";
      };
      "= /config.json".root = elementConfigPath;
    };

    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
    disableLiveCompression = true;
  };
}
