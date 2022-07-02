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
in
{
  age.secrets.asterisk-pw = {
    file = pkgs.secrets + "/asterisk-pw.age";
    owner = "asterisk";
    group = "asterisk";
  };

  services.asterisk = {
    enable = true;

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
        allow=opus,speex,speex16,speex32,ulaw,alaw
        identify_by=username,auth_username
        rewrite_contact=yes
        media_encryption=sdes

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
        exten => 1000,1,Dial(PJSIP/1000)
        exten => 1001,1,Dial(PJSIP/1001)
        exten => _X!,1,Playback(im-sorry&check-number-dial-again)
      '';
    };
  };
}
