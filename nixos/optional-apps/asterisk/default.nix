{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  inherit (pkgs.callPackage ./apps/astycrapper.nix args) dialAstyCrapper;
  inherit (pkgs.callPackage ./apps/beverly.nix args) dialBeverly;
  inherit (pkgs.callPackage ./apps/lenny.nix args) dialLenny;
  inherit (pkgs.callPackage ./common.nix args) dialRule enumerateList prefixZeros;
  inherit (pkgs.callPackage ./external-trunks.nix args) externalTrunk;
  inherit (pkgs.callPackage ./local-devices.nix args) localDevices destLocal;
  inherit (pkgs.callPackage ./musics.nix args) destLocalForwardMusic destMusic;
  inherit (pkgs.callPackage ./templates.nix args) templates;
  inherit (pkgs.callPackage ./transports.nix args) transports;

  cfg = config.services.asterisk;

  asteriskUser = "asterisk";
  asteriskGroup = "asterisk";

  varlibdir = "/var/lib/asterisk";
  spooldir = "/var/spool/asterisk";
  logdir = "/var/log/asterisk";
in {
  age.secrets.asterisk-pw = {
    file = inputs.secrets + "/asterisk-pw.age";
    owner = "asterisk";
    group = "asterisk";
  };

  services.asterisk = {
    enable = true;
    package = pkgs.lantianCustomized.asterisk;

    confFiles = {
      "pjsip.conf" = ''
        ; Allow unlimited retries for registration
        [registration]
        auth_rejection_permanent=no
        max_retries=0

        ; Transports
        ${transports}

        ; Templates
        ${templates}

        ; External trunks
        ${externalTrunk {
          name = "callcentric";
          number = "17778435933";
          url = "sip.callcentric.net";
          extraEndpointConfig = ''
            allow=!all,ulaw,alaw
            media_encryption=no
          '';
        }}
        ${externalTrunk {
          name = "sdf";
          number = "2293";
          url = "sip.sdf.org";
        }}
        ${externalTrunk {
          name = "telnyx";
          number = "recount9550";
          url = "sip.telnyx.com";
          protocol = "sips";
          extraEndpointConfig = ''
            allow=!all,opus,g722,ulaw,alaw,g729
            media_encryption_optimistic=no
          '';
        }}
        ${externalTrunk {
          name = "zadarma";
          number = "286901";
          url = "sip.zadarma.com";
        }}

        ; Anonymous calling
        [anonymous](template-endpoint-common)
        context=src-anonymous

        ; Local devices
        ${localDevices}

        ; Include passwords
        #include ${config.age.secrets.asterisk-pw.path}
      '';

      # Number plan:
      # - 0000-0099: music
      # - 0100: milliwatt (1004hz)
      # - 0101: fax receiver
      # - 0200-0299: conference room
      # - 1000-1998: real users
      # - 1999: ring group (1000 & 1001)
      # - 2000: random between all call bots
      # - 2001: lenny
      # - 2002: jordan (asty-crapper)
      #         https://web.archive.org/web/20110517174427/http://www.linuxsystems.com.au/astycrapper/
      # - 2003: beverly
      #         https://worldofprankcalls.com/beverly/
      "extensions.conf" =
        ''
          [src-anonymous]
          ; Only allow anonymous inbound call to test numbers
          ${dialRule "42402547XXXX" ["Goto(dest-local,\${EXTEN:8},1)"]}
          ${dialRule "[02-9]XXX" ["Goto(dest-local,\${EXTEN},1)"]}

          [src-local]
          ${dialRule "733XXXX" ["Dial(PJSIP/\${EXTEN:3}@sdf)"]}
          ${dialRule "42402547XXXX" ["Goto(dest-local,\${EXTEN:8},1)"]}
          ${dialRule "XXX" ["Dial(PJSIP/\${EXTEN}@telnyx)"]}
          ${dialRule "XXXX" ["Goto(dest-local,\${EXTEN},1)"]}
          ${dialRule "777XXXXXXX" ["Dial(PJSIP/1\${EXTEN}@callcentric)"]}
          ${dialRule "NXXNXXXXXX" ["Dial(PJSIP/+1\${EXTEN}@telnyx)"]}
          ${dialRule "X!" ["Goto(dest-url,\${EXTEN},1)"]}

          [src-callcentric]
          ; Remove international call prefix
          ${dialRule "+X!" ["Goto(src-callcentric,\${EXTEN:1},1)"]}
          ; All calls go to 0000
          ${dialRule "X!" ["Goto(dest-local,0000,1)"]}

          [src-sdf]
          ; Remove international call prefix
          ${dialRule "+X!" ["Goto(src-sdf,\${EXTEN:1},1)"]}
          ; All calls go to 0000
          ${dialRule "X!" ["Goto(dest-local,0000,1)"]}

          [src-telnyx]
          ; Remove international call prefix
          ${dialRule "+X!" ["Goto(src-telnyx,\${EXTEN:1},1)"]}
          ; All calls go to ring group
          ${dialRule "X!" ["Goto(dest-local,1999,1)"]}

          [src-zadarma]
          ; Remove international call prefix
          ${dialRule "+X!" ["Goto(src-zadarma,\${EXTEN:1},1)"]}
          ; All calls go to 0000
          ${dialRule "X!" ["Goto(dest-local,0000,1)"]}

          [dest-local]
          ${destLocalForwardMusic 4}
          ${dialRule "0100" ["Answer()" "Milliwatt(m)"]}
          ${dialRule "0101" ["Answer()" "ReceiveFAX(/var/lib/asterisk/fax/\${STRFTIME(\${EPOCH},,%Y%m%d-%H%M%S)}.tiff, f)"]}
          ${dialRule "02XX" ["Answer()" "ConfBridge(\${EXTEN:2})"]}
          ${destLocal}
          ${dialRule "1999" [
            "Set(DIALGROUP(mygroup,add)=PJSIP/1000)"
            "Set(DIALGROUP(mygroup,add)=PJSIP/1001)"
            "Dial(\${DIALGROUP(mygroup)})"
          ]}
          ${dialRule "2000" ["Goto(dest-local,\${RAND(2001,2003)},1)"]}
          ${dialRule "2001" ["Goto(app-lenny,b,1)"]}
          ${dialRule "2002" ["Goto(app-asty-crapper,b,1)"]}
          ${dialRule "2003" ["Goto(app-beverly,b,1)"]}
          ${dialRule "X!" ["Answer()" "Playback(im-sorry&check-number-dial-again)"]}

          [dest-music]
          ${destMusic}

          [dest-url]
          ${dialRule "X!" ["Dial(PJSIP/anonymous/sip:\${EXTEN}@\${SIPDOMAIN})"]}
        ''
        + dialAstyCrapper
        + dialBeverly
        + dialLenny;

      "codecs.conf" = builtins.readFile ./config/codecs.conf;
      "logger.conf" = builtins.readFile ./config/logger.conf;
      "res_fax.conf" = builtins.readFile ./config/res_fax.conf;
      "udptl.conf" = builtins.readFile ./config/udptl.conf;
    };
  };

  services.fail2ban.jails = {
    asterisk = ''
      enabled  = true
      filter   = asterisk-lantian
      backend  = auto
      logpath  = /var/log/asterisk/asterisk.log
    '';
    asterisk-security = ''
      enabled  = true
      filter   = asterisk-lantian
      backend  = auto
      logpath  = /var/log/asterisk/security.log
    '';
  };

  services.logrotate = {
    enable = true;
    settings = {
      asterisk = {
        files = "/var/log/asterisk/*.log";
        su = "asterisk asterisk";
        frequency = "daily";
        rotate = 5;
        copytruncate = true;
        compress = true;
      };
    };
  };

  systemd.services.asterisk = {
    path = with pkgs; [mpg123];
    reloadTriggers = lib.mapAttrsToList (k: v: "/etc/asterisk/${k}") config.services.asterisk.confFiles;

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

  systemd.tmpfiles.rules = [
    "d /var/lib/asterisk/fax 755 asterisk asterisk"
  ];
}
