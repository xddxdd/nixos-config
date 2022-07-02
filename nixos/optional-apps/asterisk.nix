{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };

  generateLocalDevice = number: ''
    [${number}](template-local-devices)
    auth=${number}
    aors=${number}
    callerid=Lan Tian <${number}>

    [${number}](template-aor)
  '';

  generateMusicDialplan = number: music: ''
    exten => ${number},1,Answer()
    same  =>           n,Playback(${pkgs.flake.nixos-asterisk-music}/${music})
    same  =>           n,Hangup()
  '';
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
      "logger.conf" = ''
        [general]

        [logfiles]
        syslog.local0 => warning,error
      '';

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

        ${generateLocalDevice "1000"}
        ${generateLocalDevice "1001"}

        ; Include passwords
        #include ${config.age.secrets.asterisk-pw.path}
      '';

      "extensions.conf" = ''
        [src-local]
        exten => _42402547X.,1,Goto(dest-local,''${EXTEN:8},1)
        exten => _X!        ,1,Goto(dest-local,''${EXTEN},1)

        [dest-local]
        ${generateMusicDialplan "0001" "nightglow"}
        ${generateMusicDialplan "0002" "rubia"}
        ${generateMusicDialplan "0003" "ye_hang_xing"}

        exten => 1000,1,Dial(PJSIP/1000)
        same  =>      n,Hangup()

        exten => 1001,1,Dial(PJSIP/1001)
        same  =>      n,Hangup()

        exten => _X!,1,Answer()
        same  =>     n,Playback(im-sorry&check-number-dial-again)
        same  =>     n,Hangup()
      '';

      "codecs.conf" = ''
        [speex]
        ; CBR encoding quality [0..10]
        ; used only when vbr = false
        quality => 10

        ; codec complexity [0..10]
        ; tradeoff between cpu/quality
        complexity => 10

        ; perceptual enhancement [true / false]
        ; improves clarity of decoded speech
        enhancement => true

        ; voice activity detection [true / false]
        ; reduces bitrate when no voice detected, used only for CBR
        ; (implicit in VBR/ABR)
        vad => true

        ; variable bit rate [true / false]
        ; uses bit rate proportionate to voice complexity
        vbr => true

        ; available bit rate [bps, 0 = off]
        ; encoding quality modulated to match this target bit rate
        ; not recommended with dtx or pp_vad - may cause bandwidth spikes
        abr => 0

        ; VBR encoding quality [0-10]
        ; floating-point values allowed
        vbr_quality => 10

        ; discontinuous transmission [true / false]
        ; stops transmitting completely when silence is detected
        ; pp_vad is far more effective but more CPU intensive
        dtx => false

        ; preprocessor configuration
        ; these options only affect Speex v1.1.8 or newer

        ; enable preprocessor [true / false]
        ; allows dsp functionality below but incurs CPU overhead
        preprocess => false

        ; preproc voice activity detection [true / false]
        ; more advanced equivalent of DTX, based on voice frequencies
        pp_vad => false

        ; preproc automatic gain control [true / false]
        pp_agc => false
        pp_agc_level => 8000

        ; preproc denoiser [true / false]
        pp_denoise => false

        ; preproc dereverb [true / false]
        pp_dereverb => false
        pp_dereverb_decay => 0.4
        pp_dereverb_level => 0.3

        ; experimental bitrate changes depending on RTCP feedback [true / false]
        experimental_rtcp_feedback => false


        [plc]
        genericplc => true
        genericplc_on_equal_codecs => false

        [silk8]
        type=silk
        samprate=8000
        maxbitrate=10000
        fec=true
        packetloss_percentage=10
        dtx=true

        [silk12]
        type=silk
        samprate=12000
        maxbitrate=12000
        fec=true
        packetloss_percentage=10;
        dtx=true

        [silk16]
        type=silk
        samprate=16000
        maxbitrate=20000
        fec=true
        packetloss_percentage=10;
        dtx=true

        [silk24]
        type=silk
        samprate=24000
        maxbitrate=30000
        fec=true
        packetloss_percentage=10;
        dtx=true

        ; Default custom CELT codec definitions. Only one custom CELT definition is allowed
        ; per a sample rate.
        ;[celt44]
        ;type=celt
        ;samprate=44100  ; The samplerate in hz. This option is required.
        ;framesize=480   ; The framesize option represents the duration of each frame in samples.
                         ; This must be a factor of 2.  This option is only advertised in an SDP
                         ; when it is set.  Otherwise a default of framesize of 480 is assumed
                         ; internally

        ;[celt48]
        ;type=celt
        ;samprate=48000

        ;[celt32]
        ;type=celt
        ;samprate=32000

        [opus]
        type=opus
        packet_loss=10
        complexity=10
        max_bandwidth=full
        signal=auto
        application=audio
        max_playback_rate=48000
        bitrate=max
        cbr=no
        fec=yes
        dtx=yes
      '';
    };
  };

  systemd.services.asterisk = {
    path = with pkgs; [ mpg123 ];
    reloadTriggers = lib.mapAttrsToList (k: v: "/etc/asterisk/${k}") config.services.asterisk.confFiles;
    reloadIfChanged = true;
  };
}
