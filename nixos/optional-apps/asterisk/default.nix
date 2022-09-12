{ config, pkgs, lib, ... }@args:

let
  LT = import ../../../helpers { inherit config pkgs; };

  inherit (pkgs.callPackage ./common.nix args) dialRule enumerateList prefixZeros;
  inherit (pkgs.callPackage ./external-trunks.nix args) externalTrunk;
  inherit (pkgs.callPackage ./local-devices.nix args) localDevices destLocal;
  inherit (pkgs.callPackage ./musics.nix args) destLocalForwardMusic destMusic;
  inherit (pkgs.callPackage ./transports.nix args) transports;

  cfg = config.services.asterisk;

  asteriskUser = "asterisk";
  asteriskGroup = "asterisk";

  varlibdir = "/var/lib/asterisk";
  spooldir = "/var/spool/asterisk";
  logdir = "/var/log/asterisk";
in
{
  age.secrets.asterisk-pw = {
    file = pkgs.secrets + "/asterisk-pw.age";
    owner = "asterisk";
    group = "asterisk";
  };

  services.asterisk = {
    enable = true;
    package = pkgs.lantianCustomized.asterisk;

    confFiles = {
      "pjsip.conf" = ''
        ;;;;;;;;;;;;;;;;;;;;;
        ; Transports
        ;;;;;;;;;;;;;;;;;;;;;
        ${transports}

        ;;;;;;;;;;;;;;;;;;;;;
        ; Templates
        ;;;;;;;;;;;;;;;;;;;;;

        [template-endpoint-common](!)
        type=endpoint
        allow=opus,g722,alaw,ulaw,speex32,speex16,g729,g726,ilbc,speex
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

        [template-endpoint-local](!)
        context=src-local
        identify_by=username,auth_username

        [template-auth](!)
        type=auth
        auth_type=userpass

        [template-aor](!)
        type=aor
        max_contacts=1
        remove_existing=yes

        ;;;;;;;;;;;;;;;;;;;;;
        ; External trunks
        ;;;;;;;;;;;;;;;;;;;;;
        ${externalTrunk { name = "zadarma"; number = "286901"; url = "sip.zadarma.com"; }}

        ;;;;;;;;;;;;;;;;;;;;;
        ; Anonymous calling
        ;;;;;;;;;;;;;;;;;;;;;

        [anonymous](template-endpoint-common)
        context=src-anonymous

        ;;;;;;;;;;;;;;;;;;;;;
        ; Local devices
        ;;;;;;;;;;;;;;;;;;;;;

        ${localDevices}

        ; Include passwords
        #include ${config.age.secrets.asterisk-pw.path}
      '';

      # Number plan:
      # - 0000-0099: music
      # - 1000-1999: real users
      "extensions.conf" = ''
        [src-anonymous]
        ; Only allow anonymous inbound call to test numbers
        ${dialRule "_424025470XXX" [ "Goto(dest-local,0\${EXTEN:9},1)" ]}
        ${dialRule "_0XXX" [ "Goto(dest-local,0\${EXTEN:1},1)" ]}

        [src-local]
        ${dialRule "_42402547XXXX" [ "Goto(dest-local,\${EXTEN:8},1)" ]}
        ${dialRule "_XXXX" [ "Goto(dest-local,\${EXTEN},1)" ]}

        [src-zadarma]
        ; All calls go to 0000
        ${dialRule "_X!" [ "Goto(dest-local,0000,1)" ]}

        [dest-local]
        ${destLocalForwardMusic 4}
        ${destLocal}
        ${dialRule "_X!" [ "Answer()" "Playback(im-sorry&check-number-dial-again)" ]}

        [dest-music]
        ${destMusic}
      '';

      "logger.conf" = builtins.readFile ./config/logger.conf;
      "codecs.conf" = builtins.readFile ./config/codecs.conf;
    };
  };

  services.fail2ban.jails.asterisk = ''
    enabled  = true
    filter   = asterisk
    backend  = auto
    logpath  = /var/log/asterisk/security.log
  '';

  systemd.services.asterisk = {
    path = with pkgs; [ mpg123 ];
    reloadTriggers = lib.mapAttrsToList (k: v: "/etc/asterisk/${k}") config.services.asterisk.confFiles;
    reloadIfChanged = true;

    preStart = ''
      # Copy skeleton directory tree to /var
      for d in '${varlibdir}' '${spooldir}' '${logdir}'; do
        mkdir -p "$d"
        cp --recursive ${cfg.package}/"$d"/* "$d"/
        chown --recursive ${asteriskUser}:${asteriskGroup} "$d"
        find "$d" -type d | xargs chmod 0755
      done
    '';
  };
}
