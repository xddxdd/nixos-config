{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };

  inherit (pkgs.callPackage ./common.nix { }) dialRule enumerateList prefixZeros;
  inherit (pkgs.callPackage ./local-devices.nix { }) localDevices destLocal;
  inherit (pkgs.callPackage ./musics.nix { }) destLocalForwardMusic destMusic;
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

        [transport-ipv4-udp]
        type=transport
        protocol=udp
        bind=0.0.0.0:5060
        local_net=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
        external_media_address=${LT.this.public.IPv4}
        external_signaling_address=${LT.this.public.IPv4}

        [transport-ipv4-tcp]
        type=transport
        protocol=tcp
        bind=0.0.0.0:5060

        [transport-ipv4-tls]
        type=transport
        protocol=tls
        bind=0.0.0.0:5061
        cert_file=${LT.nginx.getSSLCert "lantian.pub_ecc"}
        priv_key_file=${LT.nginx.getSSLKey "lantian.pub_ecc"}
        method=tlsv1_2

        [transport-ipv6-udp]
        type=transport
        protocol=udp
        bind=[::]:5060

        [transport-ipv6-tcp]
        type=transport
        protocol=tcp
        bind=[::]:5060

        [transport-ipv6-tls]
        type=transport
        protocol=tls
        bind=[::]:5061
        cert_file=${LT.nginx.getSSLCert "lantian.pub_ecc"}
        priv_key_file=${LT.nginx.getSSLKey "lantian.pub_ecc"}
        method=tlsv1_2

        ;;;;;;;;;;;;;;;;;;;;;
        ; Templates
        ;;;;;;;;;;;;;;;;;;;;;

        [template-local-devices](!)
        type=endpoint
        context=src-local
        allow=speex32,g722,speex16,g729,g726,ilbc,speex,opus,alaw,ulaw
        identify_by=username,auth_username
        rewrite_contact=yes
        media_encryption=sdes
        media_encryption_optimistic=yes

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
