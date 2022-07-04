{ config, pkgs, lib, ... }@args:

let
  LT = import ../../../helpers { inherit config pkgs; };

  inherit (pkgs.callPackage ./common.nix args) dialRule enumerateList prefixZeros;
  inherit (pkgs.callPackage ./local-devices.nix args) localDevices destLocal;
  inherit (pkgs.callPackage ./musics.nix args) destLocalForwardMusic destMusic;
  inherit (pkgs.callPackage ./transports.nix args) transports;
in
{
  age.secrets.asterisk-pw = {
    file = pkgs.secrets + "/asterisk-pw.age";
    owner = "asterisk";
    group = "asterisk";
  };

  services.asterisk = {
    enable = true;
    package = pkgs.asterisk.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        ln -s ${pkgs.asterisk-g72x}/lib/asterisk/modules/codec_g729.so $out/lib/asterisk/modules/codec_g729.so
      '';
    });

    confFiles = {
      "pjsip.conf" = ''
        ;;;;;;;;;;;;;;;;;;;;;
        ; Transports
        ;;;;;;;;;;;;;;;;;;;;;
        ${transports}

        ;;;;;;;;;;;;;;;;;;;;;
        ; Templates
        ;;;;;;;;;;;;;;;;;;;;;

        [template-local-devices](!)
        type=endpoint
        context=src-local
        allow=g722,alaw,ulaw,opus,speex32,speex16,g729,g726,ilbc,speex
        identify_by=username,auth_username
        direct_media=no
        rtp_symmetric=yes
        force_rport=yes
        rewrite_contact=yes
        media_encryption=sdes
        media_encryption_optimistic=yes
        tos_audio=ef
        cos_audio=5
        tos_video=af41
        cos_audio=4

        [template-auth](!)
        type=auth
        auth_type=userpass

        [template-aor](!)
        type=aor
        max_contacts=1
        remove_existing=yes

        ;;;;;;;;;;;;;;;;;;;;;
        ; Local devices
        ;;;;;;;;;;;;;;;;;;;;;

        ${localDevices}

        ; Include passwords
        #include ${config.age.secrets.asterisk-pw.path}
      '';

      "extensions.conf" = ''
        [src-local]
        ${dialRule "_42402547X." [
          "Goto(dest-local,\${EXTEN:8},1)"
        ]}
        ${dialRule "_X!" [
          "Goto(dest-local,\${EXTEN},1)"
        ]}

        [dest-local]
        ${destLocalForwardMusic 4}
        ${destLocal}

        exten => _X!,1,Answer()
        same  =>     n,Playback(im-sorry&check-number-dial-again)
        same  =>     n,Hangup()

        [dest-music]
        ${destMusic}
      '';

      "logger.conf" = builtins.readFile ./config/logger.conf;
      "codecs.conf" = builtins.readFile ./config/codecs.conf;
    };
  };

  systemd.services.asterisk = {
    path = with pkgs; [ mpg123 ];
    reloadTriggers = lib.mapAttrsToList (k: v: "/etc/asterisk/${k}") config.services.asterisk.confFiles;
    reloadIfChanged = true;
  };
}
