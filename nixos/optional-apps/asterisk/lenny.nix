{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };

  lenny = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "lenny";
    version = "8636f56849954fa7598eefc9f79aeb1dc14b10e7";
    src = pkgs.fetchFromGitHub {
      owner = "VitalPBX";
      repo = "Telemarketers-with-Lenny";
      rev = version;
      sha256 = "sha256-DaFAiKd3wLK1WcPb7gb8QT+QZ/JCoRymW2DrahFy8oE=";
    };

    installPhase = ''
      mkdir -p $out
      cp -r audios/* $out/
    '';
  };
in
{
  dialLenny = ''
    exten => talk,1,Set(i=''${IF($["0''${i}"="016"]?7:$[0''${i}+1])})
    same => n,Playback(${lenny}/Lenny''${i})
    same => n,BackgroundDetect(${lenny}/backgroundnoise,1500)
  '';
}
