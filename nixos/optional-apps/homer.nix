{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  homer = pkgs.stdenvNoCC.mkDerivation {
    inherit (LT.sources.homer) pname version src;
    nativeBuildInputs = with pkgs; [unzip];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
in {
  programs.chromium.extraOpts.HomepageLocation = lib.mkForce "http://localhost";
  programs.firefox.policies.Homepage.URL = lib.mkForce "http://localhost";

  services.nginx.virtualHosts."localhost" = lib.mkForce {
    listen = LT.nginx.listenHTTP;
    root = pkgs.linkFarm "homer" {
      "_custom" = "/var/www/localhost";
      "_homer" = homer;
    };
    # try_files + alias won't work because https://trac.nginx.org/nginx/ticket/97
    locations = {
      "= /".tryFiles = "/_homer/index.html $uri =404";
      "/" = {
        index = "index.html";
        tryFiles = "$uri /_custom$uri /_homer$uri =404";
      };
    };
    extraConfig =
      LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true
      + LT.nginx.serveLocalhost;
  };

  systemd.tmpfiles.rules = [
    "L+ /var/www/localhost/_dashboard-icons - - - - ${LT.sources.dashboard-icons.src}"
  ];
}
