{
  pkgs,
  lib,
  dns,
  ...
} @ args: let
  inherit (pkgs.callPackage ./host-recs.nix args) fakeALIAS;
in
  with dns; rec {
    Autoconfig = domain: [
      (CNAME {
        name = "autoconfig";
        target = GeoDNSTarget;
        ttl = "1h";
      })
      (SRV {
        name = "_autodiscover._tcp";
        priority = 0;
        weight = 0;
        port = 443;
        target = "autoconfig.${domain}.";
      })
    ];

    ForwardEmail = [
      (MX {
        name = "@";
        priority = 10;
        target = "mx1.forwardemail.net.";
      })
      (MX {
        name = "@";
        priority = 10;
        target = "mx2.forwardemail.net.";
      })
      (MX {
        name = "@";
        priority = 20;
        target = "mx.mailtie.com.";
      })
      (TXT {
        name = "@";
        contents = "v=DMARC1; p=none";
      })
      (TXT {
        name = "@";
        contents = "v=spf1 a mx include:spf.forwardemail.net -all";
      })
      (TXT {
        name = "@";
        contents = "forward-email=xuyh0120@gmail.com";
      })
      (TXT {
        name = "@";
        contents = "mailtie=xuyh0120@gmail.com";
      })
      (TXT {
        name = "_dmarc";
        contents = "v=DMARC1; p=none";
      })
    ];

    GeoDNSTarget = "geo.56631131.xyz."; # Hosted on NS1.com for GeoDNS

    Libravatar = [
      (fakeALIAS {
        name = "avatar";
        target = "v-ps-sjc";
        ttl = "1h";
      })

      # Use fixed domain, vhost not set up for all domains for now
      (SRV {
        name = "_avatars._tcp";
        priority = 0;
        weight = 0;
        port = 80;
        target = "avatar.lantian.pub.";
      })
      (SRV {
        name = "_avatars-sec._tcp";
        priority = 0;
        weight = 0;
        port = 443;
        target = "avatar.lantian.pub.";
      })
    ];

    MXRoute = [
      (MX {
        name = "@";
        priority = 10;
        target = "witcher.mxrouting.net.";
      })
      (MX {
        name = "@";
        priority = 20;
        target = "witcher-relay.mxrouting.net.";
      })
      (TXT {
        name = "@";
        contents = "v=DMARC1; p=none";
      })
      (TXT {
        name = "_dmarc";
        contents = "v=DMARC1; p=none";
      })
      (TXT {
        name = "@";
        contents = "v=spf1 include:mxlogin.com -all";
      })
      (TXT {
        name = "x._domainkey";
        contents = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnoMpO+zy8KOzcOnUJzKXAHPIZUqusUQjCgJj6ErpKR8oi5kXA5yLLeAZaNl6fh3Au2GfHJTFTkYCUSfL4dt4A7x8FV8rNlrpTmU/SQ1+VfvtS/Qn5uwROmAiKMmjhL8KvuyCEEvTHsBZLIpDDhu+K10N5s3khy4KlVetNhFeahV6wFn/GbnfKHjsfkF3IWLvOtafqNFb8/VH8LsgsCtUJjniecD9D37iqcwxGqUPolx30D8ZXnuMpcS9Ylh6HvCbUHwbdiGm4YmplhvwiWRiTFDL9hyyLOL1cddtoMHZLm3cUP87d2nGIINQJoRHQTWuOp8UsgHJ6eNZ6E62WsYeTQIDAQAB";
      })
    ];

    ProxmoxCluster = [
      (A {
        name = "lt-epyc";
        address = "192.168.0.2";
        ttl = "1h";
      })
      (A {
        name = "lt-hp-z220-sff";
        address = "192.168.0.3";
        ttl = "1h";
      })
      (A {
        name = "lt-wyse";
        address = "192.168.0.4";
        ttl = "1h";
      })
    ];

    SIP = [
      (SRV {
        name = "_sip._udp";
        priority = 0;
        weight = 0;
        port = 5060;
        target = "vultr-sea";
      })
      (SRV {
        name = "_sip._tcp";
        priority = 0;
        weight = 0;
        port = 5060;
        target = "vultr-sea";
      })
      (SRV {
        name = "_sips._tcp";
        priority = 0;
        weight = 0;
        port = 5061;
        target = "vultr-sea";
      })
    ];
  }
