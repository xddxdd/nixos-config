{
  pkgs,
  lib,
  config,
  inputs,
  LT,
  ...
}@args:
let
  sipPorts = {
    tcpPorts = {
      "${LT.portStr.Asterisk.SIP.Public}".type = "local";
      "${LT.portStr.Asterisk.SIP.TLS}".type = "local";
    };
    udpPorts = {
      "${LT.portStr.Asterisk.SIP.Public}".type = "local";
      "${LT.portStr.Asterisk.UDPTL.Start}-${LT.portStr.Asterisk.UDPTL.End}".type = "local";
      "${LT.portStr.Asterisk.RTP.Start}-${LT.portStr.Asterisk.RTP.End}".type = "local";
    };
  };
  ltnetSipPorts = sipPorts // {
    tcpPorts = sipPorts.tcpPorts // {
      "${LT.portStr.Prometheus.Asterisk}".type = "local";
    };
  };

  # keep-sorted start
  inherit (pkgs.callPackage ./extensions.nix args) extensions;
  inherit (pkgs.callPackage ./external-trunks.nix args) externalTrunk;
  inherit (pkgs.callPackage ./local-devices.nix args) localDevices;
  inherit (pkgs.callPackage ./templates.nix args) templates;
  inherit (pkgs.callPackage ./transports.nix args) transports;
  # keep-sorted end

  cfg = config.services.asterisk;

  # RTP/UDPTL media port ranges are declared in LT.port
  # (Asterisk.RTP.Start/End, Asterisk.UDPTL.Start/End) so the firewall
  # whitelist can accept exactly those ranges; the previous default bound a
  # random per-call port scattered across 5000-65500 which a whitelist
  # cannot enumerate.

  varlibdir = "/var/lib/asterisk";
  spooldir = "/var/spool/asterisk";
  logdir = "/var/log/asterisk";

  asterisk-cli = pkgs.runCommand "asterisk-cli" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe cfg.package} $out/bin/asterisk-cli \
      --add-flag "-C" \
      --add-flag "/etc/asterisk/asterisk.conf" \
      --add-flag "-r"
  '';
in
{
  imports = [
    ./dialplan
    ./fax-monitor.nix
    ./never-gonna-audiosocket.nix
    ../fail2ban
  ];

  sops.secrets.asterisk-pw = {
    sopsFile = inputs.secrets + "/asterisk.yaml";
    owner = "asterisk";
    group = "asterisk";
  };

  environment.systemPackages = [
    asterisk-cli
    pkgs.sngrep
  ];

  services.asterisk = {
    enable = true;
    package = pkgs.nur-xddxdd.lantianCustomized.asterisk;

    confFiles = {
      "modules.conf" = ''
        [modules]
        autoload=no

        ; extensions.conf、ENUM/AGI 及其依赖；res_speech 是 res_agi 的必需依赖。
        load => pbx_config.so
        load => res_speech.so
        load => res_agi.so
        load => app_audiosocket.so
        load => res_audiosocket.so
        load => app_confbridge.so
        load => app_dial.so
        load => app_milliwatt.so
        load => app_mixmonitor.so
        load => app_mp3.so
        load => app_playback.so
        load => app_read.so
        load => app_senddtmf.so
        load => app_talkdetect.so
        load => app_verbose.so
        load => func_callerid.so
        load => func_channel.so
        load => func_cut.so
        load => func_dialgroup.so
        load => func_enum.so
        load => func_logic.so
        load => func_rand.so
        load => func_strings.so
        load => func_uuid.so

        ; 保留 templates.nix 中公布的音频编解码器及音视频 SDP 属性。
        load => codec_a_mu.so
        load => codec_alaw.so
        load => codec_amr.so
        load => codec_evs.so
        load => codec_g722.so
        load => codec_g726.so
        load => codec_g729.so
        load => codec_gsm.so
        load => codec_gsm_efr.so
        load => codec_ilbc.so
        load => codec_opus.so
        load => codec_resample.so
        load => codec_silk.so
        load => codec_siren7.so
        load => codec_siren14.so
        load => codec_speex.so
        load => codec_ulaw.so
        load => res_format_attr_amr.so
        load => res_format_attr_evs.so
        load => res_format_attr_g729.so
        load => res_format_attr_h263.so
        load => res_format_attr_h264.so
        load => res_format_attr_ilbc.so
        load => res_format_attr_opus.so
        load => res_format_attr_silk.so
        load => res_format_attr_siren7.so
        load => res_format_attr_siren14.so
        load => res_format_attr_vp8.so

        ; 提示音、机器人录音和等待音乐；MP3Player 通过 FFmpeg 解码，无需 format_mp3。
        load => format_gsm.so
        load => format_pcm.so
        load => format_wav.so
        load => res_musiconhold.so
        load => res_fax.so
        load => res_fax_spandsp.so
        load => bridge_simple.so
        load => bridge_softmix.so
        load => res_timing_timerfd.so

        ; PJSIP 基础依赖；chan_pjsip 即使不使用订阅也需要 pubsub。
        load => res_sorcery_config.so
        load => res_sorcery_memory.so
        load => res_sorcery_astdb.so
        load => res_pjproject.so
        load => res_pjsip.so
        load => res_pjsip_session.so
        load => res_pjsip_pubsub.so
        load => chan_pjsip.so
        load => res_rtp_asterisk.so
        load => res_srtp.so

        ; 手机注册、外部中继、匿名/ENUM 呼叫、消息、NAT、T.38 和 SIP 转接。
        load => res_pjsip_authenticator_digest.so
        load => res_pjsip_outbound_authenticator_digest.so
        load => res_pjsip_registrar.so
        load => res_pjsip_outbound_registration.so
        load => res_pjsip_endpoint_identifier_user.so
        load => res_pjsip_endpoint_identifier_ip.so
        load => res_pjsip_endpoint_identifier_anonymous.so
        load => res_pjsip_messaging.so
        load => res_pjsip_nat.so
        load => res_pjsip_caller_id.so
        load => res_pjsip_sdp_rtp.so
        load => res_pjsip_t38.so
        load => res_pjsip_sips_contact.so
        load => res_pjsip_refer.so
        load => res_pjsip_diversion.so
        load => res_pjsip_rfc3326.so
        load => res_pjsip_dlg_options.so

        ; Prometheus 与 fail2ban 使用的安全日志。
        load => res_prometheus.so
        load => res_security_log.so
      '';

      "pjsip.conf" = ''
        [system]
        timer_b=8000

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
          number = "912098";
          url = "sip.zadarma.com";
        }}

        ; Anonymous calling
        [anonymous](template-endpoint-common)
        context=src-anonymous
        message_context=src-anonymous-message

        ; Local devices
        ${localDevices}

        ; DN42 ENUM
        [dn42-enum](template-endpoint-common)
        transport=transport-ipv4-udp-dn42
        transport=transport-ipv4-tcp-dn42
        transport=transport-ipv4-tls-dn42
        transport=transport-ipv6-udp-dn42
        transport=transport-ipv6-tcp-dn42
        transport=transport-ipv6-tls-dn42
        transport=transport-ipv6-alt-udp-dn42
        transport=transport-ipv6-alt-tcp-dn42
        transport=transport-ipv6-alt-tls-dn42
        context=src-peers-enum
        message_context=src-peers-enum-message
        from_domain=lantian.dn42

        [dn42-enum]
        type=identify
        endpoint=dn42-enum
        match=172.20.0.0/14
        match=10.0.0.0/8
        match=172.31.0.0/16
        match=fd00::/8

        [dn42-enum-outbound](template-endpoint-common)
        from_domain=lantian.dn42

        ; Include passwords
        #include ${config.sops.secrets.asterisk-pw.path}
      '';

      # Keep number plan in sync with dialplan/
      "extensions.conf" = extensions;

      "http.conf" = ''
        [general]
        enabled=yes
        bindaddr=${LT.this.ltnet.IPv4}
        bindport=${LT.portStr.Prometheus.Asterisk}
      '';
      "prometheus.conf" = ''
        [general]
        enabled=yes
        uri=metrics
      '';

      "codecs.conf" = builtins.readFile ./config/codecs.conf;
      "logger.conf" = builtins.readFile ./config/logger.conf;
      "res_fax.conf" = builtins.readFile ./config/res_fax.conf;
      "udptl.conf" = ''
        ;
        ; UDPTL Configuration (UDPTL is one of the transports for T.38)
        ;
        [general]
        ;
        ; UDPTL start and UDPTL end configure start and end addresses
        ;
        udptlstart=${LT.portStr.Asterisk.UDPTL.Start}
        udptlend=${LT.portStr.Asterisk.UDPTL.End}
        ;
        ; Whether to enable or disable UDP checksums on UDPTL traffic
        ;
        ;udptlchecksums=no
        ;
        ; The number of error correction entries in a UDPTL packet
        ;
        udptlfecentries = 3
        ;
        ; The span over which parity is calculated for FEC in a UDPTL packet
        ;
        udptlfecspan = 3
        ;
        ; Some VoIP providers will only accept an offer with an even-numbered
        ; UDPTL port. Set this option so that Asterisk will only attempt to
        ; use even-numbered ports when negotiating T.38. Default is no.
        use_even_ports = yes
      '';
      "rtp.conf" = ''
        [general]
        rtpstart=${LT.portStr.Asterisk.RTP.Start}
        rtpend=${LT.portStr.Asterisk.RTP.End}
      '';
    };
  };

  # SIP signaling on the public IP, DN42 addresses and LTnet IPv6
  # (transports.nix) plus UDP media ranges: T.38 UDPTL and RTP.
  lantian.firewall.zones = {
    WAN = sipPorts;
    DN42 = sipPorts;
    LTNET = ltnetSipPorts;
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
    wants = [ "asterisk-never-gonna.socket" ];
    after = [ "asterisk-never-gonna.socket" ];

    path =
      let
        skip-silence = pkgs.callPackage ../../../pkgs/skip-silence { };
        ffmpeg-wrapped = pkgs.writeShellScriptBin "ffmpeg" ''
          ${lib.getExe pkgs.ffmpeg} "$@" | ${lib.getExe skip-silence}
        '';
      in
      [
        ffmpeg-wrapped
        pkgs.coreutils
        pkgs.findutils
      ];
    restartIfChanged = lib.mkForce true;
    restartTriggers = [ config.environment.etc."asterisk/modules.conf".source ];
    reloadTriggers = lib.mapAttrsToList (k: v: "/etc/asterisk/${k}") cfg.confFiles;

    preStart = lib.mkForce ''
      # Copy skeleton directory tree to /var
      for d in '${varlibdir}' '${spooldir}' '${logdir}'; do
        if [ ! -f "$d/.initialized" ]; then
          mkdir -p "$d"
          cp --recursive ${cfg.package}/"$d"/* "$d"/
          find "$d" -type d | xargs chmod 0755
          touch "$d/.initialized"
        fi
      done
    '';
    serviceConfig = {
      User = "asterisk";
      Group = "asterisk";
      Restart = "always";
      RestartSec = "5s";
      # Do not switch user with -U flag
      ExecStart = lib.mkForce "${lib.getExe cfg.package} -C /etc/asterisk/asterisk.conf -F";
      BindReadOnlyPaths = [ "/nix/sync-servers/acme" ];
      BindPaths = [
        "/var/spool/asterisk"
      ];
      LogsDirectory = "asterisk";
      RuntimeDirectory = "asterisk";
      StateDirectory = "asterisk";
    };
    confinement.packages = [
      # sounds symlink target created by tmpfiles, absent from unit closure
      LT.sources.anti-fooling-hot-line.src
    ];
  };
  lantian.harden.asterisk = {
    enable = true;
    secret = true;
    etc = lib.mapAttrs (_: _: true) (
      lib.filterAttrs (n: v: lib.hasPrefix "asterisk/" n && v.enable) config.environment.etc
    );
  };

  environment.etc = {
    "asterisk/cdr_syslog.conf".enable = false;
    "asterisk/phone.conf".enable = false;
  };

  systemd.tmpfiles.settings = {
    asterisk = {
      "/var/lib/asterisk/fax".d = {
        mode = "755";
        user = "asterisk";
        group = "asterisk";
      };
      "/var/lib/asterisk/sounds/en/防忽悠咨询热线"."L+" = {
        argument = "${LT.sources.anti-fooling-hot-line.src}";
      };
      "/var/spool/asterisk".d = {
        mode = "755";
        user = "asterisk";
        group = "asterisk";
      };
    };
  };
}
