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
    [app-lenny]
    exten => b,1,Ringing()
    same => n,Wait(''${RAND(2,10)})
    same => n,Answer()
    same => n,Goto(app-lenny-loop,talk,1)

    [app-lenny-loop]
    exten => talk,1,Set(i=''${IF($["0''${i}"="016"]?7:$[0''${i}+1])})
    exten => talk,2,Playback(${lenny}/Lenny''${i})
    exten => talk,3,BackgroundDetect(${lenny}/backgroundnoise,1500)
    exten => talk,4,Goto(app-lenny-loop,talk,3)
  '';
}
