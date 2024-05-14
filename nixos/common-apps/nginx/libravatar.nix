{ pkgs, ... }:
let
  avatars = pkgs.stdenv.mkDerivation rec {
    pname = "avatars";
    version = "1.0";
    src = ./files/avatar.jpg;
    phases = [ "installPhase" ];
    nativeBuildInputs = with pkgs; [
      imagemagick
      jpegoptim
    ];
    installPhase = ''
      mkdir -p $out
      for SIZE in {1..512}; do
        convert $src -resize ''${SIZE}x''${SIZE}! $out/avatar-''${SIZE}.jpg
        jpegoptim --strip-all $out/avatar-''${SIZE}.jpg
      done
    '';
  };
in
{
  lantian.nginxVhosts."avatar.lantian.pub" = {
    root = avatars;
    locations = {
      "/".tryFiles = "/avatar-$arg_s.jpg /avatar-80.jpg =404";
    };
    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
  };
}
