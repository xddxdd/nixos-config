{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
} @ args: {
  common.records = rec {
    Autoconfig = domain: [
      {
        recordType = "CNAME";
        name = "autoconfig";
        target = GeoDNSTarget;
        ttl = "1h";
      }
      {
        recordType = "SRV";
        name = "_autodiscover._tcp";
        priority = 0;
        weight = 0;
        port = 443;
        target = "autoconfig.${domain}.";
      }
    ];

    ForwardEmail = [
      {
        recordType = "MX";
        name = "@";
        priority = 10;
        target = "mx1.forwardemail.net.";
      }
      {
        recordType = "MX";
        name = "@";
        priority = 10;
        target = "mx2.forwardemail.net.";
      }
      {
        recordType = "MX";
        name = "@";
        priority = 20;
        target = "mx.mailtie.com.";
      }
      {
        recordType = "TXT";
        name = "@";
        contents = "v=DMARC1; p=none";
      }
      {
        recordType = "TXT";
        name = "@";
        contents = "v=spf1 a mx include:spf.forwardemail.net -all";
      }
      {
        recordType = "TXT";
        name = "@";
        contents = "forward-email=xuyh0120@gmail.com";
      }
      {
        recordType = "TXT";
        name = "@";
        contents = "mailtie=xuyh0120@gmail.com";
      }
      {
        recordType = "TXT";
        name = "_dmarc";
        contents = "v=DMARC1; p=none";
      }
    ];

    GeoDNSTarget = "geo.56631131.xyz."; # Hosted on NS1.com for GeoDNS
    GeoStorDNSTarget = "geo-stor.56631131.xyz."; # Hosted on NS1.com for GeoDNS

    GeoRecords = [
      {
        recordType = "GEO";
        # GeoDNS for public facing servers
        name = "geo";
        ttl = "5m";
        filter = n: v:
          (builtins.elem "server" v.tags)
          && (builtins.elem "public-facing" v.tags);
      }
      {
        recordType = "GEO";
        # GeoDNS for servers with sufficient storage
        name = "geo-stor";
        ttl = "5m";
        filter = n: v:
          (builtins.elem "server" v.tags)
          && (builtins.elem "public-facing" v.tags)
          && (!(builtins.elem "low-disk" v.tags));
      }
    ];

    Libravatar = [
      {
        recordType = "fakeALIAS";
        name = "avatar";
        target = "v-ps-sjc";
        ttl = "1h";
      }

      # Use fixed domain, vhost not set up for all domains for now
      {
        recordType = "SRV";
        name = "_avatars._tcp";
        priority = 0;
        weight = 0;
        port = 80;
        target = "avatar.lantian.pub.";
      }
      {
        recordType = "SRV";
        name = "_avatars-sec._tcp";
        priority = 0;
        weight = 0;
        port = 443;
        target = "avatar.lantian.pub.";
      }
    ];

    MXRoute = [
      {
        recordType = "MX";
        name = "@";
        priority = 10;
        target = "witcher.mxrouting.net.";
      }
      {
        recordType = "MX";
        name = "@";
        priority = 20;
        target = "witcher-relay.mxrouting.net.";
      }
      {
        recordType = "TXT";
        name = "@";
        contents = "v=DMARC1; p=none";
      }
      {
        recordType = "TXT";
        name = "_dmarc";
        contents = "v=DMARC1; p=none";
      }
      {
        recordType = "TXT";
        name = "@";
        contents = "v=spf1 include:mxlogin.com -all";
      }
      {
        recordType = "TXT";
        name = "x._domainkey";
        contents = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnoMpO+zy8KOzcOnUJzKXAHPIZUqusUQjCgJj6ErpKR8oi5kXA5yLLeAZaNl6fh3Au2GfHJTFTkYCUSfL4dt4A7x8FV8rNlrpTmU/SQ1+VfvtS/Qn5uwROmAiKMmjhL8KvuyCEEvTHsBZLIpDDhu+K10N5s3khy4KlVetNhFeahV6wFn/GbnfKHjsfkF3IWLvOtafqNFb8/VH8LsgsCtUJjniecD9D37iqcwxGqUPolx30D8ZXnuMpcS9Ylh6HvCbUHwbdiGm4YmplhvwiWRiTFDL9hyyLOL1cddtoMHZLm3cUP87d2nGIINQJoRHQTWuOp8UsgHJ6eNZ6E62WsYeTQIDAQAB";
      }
    ];

    ProxmoxCluster = [
      {
        recordType = "A";
        name = "lt-epyc";
        address = "192.168.0.2";
        ttl = "1h";
      }
      {
        recordType = "A";
        name = "lt-hp-z220-sff";
        address = "192.168.0.3";
        ttl = "1h";
      }
      {
        recordType = "A";
        name = "lt-wyse";
        address = "192.168.0.4";
        ttl = "1h";
      }
    ];

    SIP = [
      {
        recordType = "SRV";
        name = "_sip._udp";
        priority = 0;
        weight = 0;
        port = 5060;
        target = "vultr-sea";
      }
      {
        recordType = "SRV";
        name = "_sip._tcp";
        priority = 0;
        weight = 0;
        port = 5060;
        target = "vultr-sea";
      }
      {
        recordType = "SRV";
        name = "_sips._tcp";
        priority = 0;
        weight = 0;
        port = 5061;
        target = "vultr-sea";
      }
    ];
  };
}
