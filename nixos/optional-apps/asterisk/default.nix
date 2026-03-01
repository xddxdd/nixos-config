{
  pkgs,
  lib,
  config,
  inputs,
  ...
}@args:
let
  # keep-sorted start
  inherit (pkgs.callPackage ./extensions.nix args) extensions;
  inherit (pkgs.callPackage ./external-trunks.nix args) externalTrunk;
  inherit (pkgs.callPackage ./local-devices.nix args) localDevices;
  inherit (pkgs.callPackage ./peers.nix args) peers;
  inherit (pkgs.callPackage ./templates.nix args) templates;
  inherit (pkgs.callPackage ./transports.nix args) transports;
  # keep-sorted end

  cfg = config.services.asterisk;

  asteriskUser = "asterisk";
  asteriskGroup = "asterisk";

  varlibdir = "/var/lib/asterisk";
  spooldir = "/var/spool/asterisk";
  logdir = "/var/log/asterisk";

  asterisk-cli = pkgs.runCommand "asterisk-cli" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe config.services.asterisk.package} $out/bin/asterisk-cli \
      --add-flag "-C" \
      --add-flag "/etc/asterisk/asterisk.conf" \
      --add-flag "-r"
  '';
in
{
  imports = [
    ./dialplan.nix
    ../fail2ban
  ];

  age.secrets.asterisk-pw = {
    file = inputs.secrets + "/asterisk-pw.age";
    owner = "asterisk";
    group = "asterisk";
  };

  environment.systemPackages = [ asterisk-cli ];

  services.asterisk = {
    enable = true;
    package = pkgs.nur-xddxdd.lantianCustomized.asterisk;

    confFiles = {
      "pjsip.conf" = ''
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
          number = "538277";
          url = "sip.zadarma.com";
        }}

        ; Anonymous calling
        [anonymous](template-endpoint-common)
        context=src-anonymous
        message_context=src-anonymous-message

        ; Local devices
        ${localDevices}

        ; Peers
        ${peers}

        ; Include passwords
        #include ${config.age.secrets.asterisk-pw.path}
      '';

      # Keep number plan in sync with dialplan.nix
      "extensions.conf" = extensions;

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
    path =
      let
        skip-silence = pkgs.callPackage ../../../pkgs/skip-silence { };
        ffmpeg-wrapped = pkgs.writeShellScriptBin "ffmpeg" ''
          ${lib.getExe pkgs.ffmpeg} "$@" | ${lib.getExe skip-silence}
        '';
      in
      [ ffmpeg-wrapped ];
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

    serviceConfig.Restart = "always";
  };

  systemd.tmpfiles.settings = {
    asterisk = {
      "/var/lib/asterisk/fax".d = {
        mode = "755";
        user = "asterisk";
        group = "asterisk";
      };
    };
  };
}
