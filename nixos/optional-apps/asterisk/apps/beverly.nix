{ pkgs, ... }:
let
  beverly = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "beverly";
    version = "1.0";
    src = pkgs.fetchzip {
      url = "https://worldofprankcalls.com/wp-content/uploads/2021/08/BeverlyBot.zip";
      stripRoot = false;
      sha256 = "sha256-K2iX42P4dJXDZ7BB4EfoRPQ8RwOduDyr+7SWNsO6Vrw=";
    };

    installPhase = ''
      mkdir -p $out
      cp * $out/
    '';
  };
in
{
  dialBeverly = ''
    [app-beverly]
    exten => b,1,Ringing()
    same => n,Wait(''${RAND(2,10)})
    same => n,Answer()
    same => n,Goto(app-beverly-loop,talk,1)

    [app-beverly-loop]
    exten => talk,1,Set(i=''${IF($["0''${i}"="037"]?7:$[0''${i}+1])})
    exten => talk,2,Playback(${beverly}/Beverly''${i})
    exten => talk,3,BackgroundDetect(${beverly}/backgroundnoise,1500)
    exten => talk,4,Goto(app-beverly-loop,talk,3)
  '';
}
