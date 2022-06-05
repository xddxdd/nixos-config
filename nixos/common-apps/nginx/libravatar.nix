{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs lib; };

  avatars = pkgs.stdenv.mkDerivation rec {
    pname = "avatars";
    version = "1.0";
    src = ./files/avatar.jpg;
    phases = [ "installPhase" ];
    nativeBuildInputs = with pkgs; [ imagemagick jpegoptim ];
    installPhase = ''
      mkdir -p $out
      for SIZE in {1..512}; do
        convert ${src} -resize ''${SIZE}x''${SIZE}! $out/avatar-''${SIZE}.jpg
        jpegoptim --strip-all $out/avatar-''${SIZE}.jpg
      done
    '';
  };
in
{
  services.nginx.virtualHosts."avatar.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    root = "${avatars}";
    locations = LT.nginx.addCommonLocationConf { } {
      "/".extraConfig = ''
        try_files /avatar-$arg_s.jpg /avatar-80.jpg =404;
      '';
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };
}
