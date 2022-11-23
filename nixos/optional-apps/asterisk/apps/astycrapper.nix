{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../../helpers args;

  astyCrapper = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "asty-crapper";
    version = "1.0";
    src = pkgs.fetchurl {
      url = "https://web.archive.org/web/20110217104551/http://www.linuxsystems.com.au/astycrapper/samples.tar.gz";
      sha256 = "sha256-M/MjqHgSjktihIPLqZt1zSPMvYl2u63xsCVJb/HM3z0=";
    };

    buildPhase = ''
      tar xf hellos.tar.gz
      tar xf jordan.tar.gz
    '';

    installPhase = ''
      mkdir -p $out/hellos $out/jordan
      cp hellos/2.gsm $out/hellos/1.gsm
      cp hellos/3.gsm $out/hellos/2.gsm
      cp jordan/* $out/jordan/
    '';
  };
in
{
  dialAstyCrapper = ''
    [app-asty-crapper]
    exten => b,1,Ringing()
    same => n,Wait(''${RAND(2,10)})
    same => n,Answer()
    same => n,Goto(app-asty-crapper-hello,b,1)

    [app-asty-crapper-hello]
    exten => b,1,Set(HELLO=''${IF($["0''${HELLO}"="02"]?1:$[0''${HELLO}+1])})
    same => n,Playback(${astyCrapper}/hellos/''${HELLO})
    same => n,BackgroundDetect(silence/10,1500)
    same => n,Goto(app-asty-crapper-hello,b,1)
    exten => talk,1,Goto(app-asty-crapper-loop,b,1)

    [app-asty-crapper-loop]
    exten => b,1,Set(LOOP=''${IF($["0''${LOOP}"="011"]?1:$[0''${LOOP}+1])})
    same => n,Playback(${astyCrapper}/jordan/''${LOOP})
    same => n,BackgroundDetect(silence/10,1500)
    same => n,Goto(app-asty-crapper-hello,b,1)
    exten => talk,1,Goto(app-asty-crapper-loop,b,1)
  '';
}
