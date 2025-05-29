{ config, ... }:
{
  common.records = rec {
    Autoconfig = domain: [
      {
        recordType = "CNAME";
        name = config.common.concatDomain "autoconfig" domain;
        target = GeoDNSTarget;
        ttl = "1h";
      }
      {
        recordType = "SRV";
        name = config.common.concatDomain "_autodiscover._tcp" domain;
        priority = 0;
        weight = 0;
        port = 443;
        target = config.common.concatDomain "autoconfig" domain;
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

    GeoDNSTarget = "lantian.pub.";
    GeoStorDNSTarget = "tools.lantian.pub.";

    Libravatar = [
      {
        recordType = "fakeALIAS";
        name = "avatar";
        target = "hetzner-de";
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

    Email = [
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
        contents = "v=spf1 include:mxlogin.com include:spf.ahasend.com -all";
      }
      # MXRoute
      {
        recordType = "TXT";
        name = "x._domainkey";
        contents = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnoMpO+zy8KOzcOnUJzKXAHPIZUqusUQjCgJj6ErpKR8oi5kXA5yLLeAZaNl6fh3Au2GfHJTFTkYCUSfL4dt4A7x8FV8rNlrpTmU/SQ1+VfvtS/Qn5uwROmAiKMmjhL8KvuyCEEvTHsBZLIpDDhu+K10N5s3khy4KlVetNhFeahV6wFn/GbnfKHjsfkF3IWLvOtafqNFb8/VH8LsgsCtUJjniecD9D37iqcwxGqUPolx30D8ZXnuMpcS9Ylh6HvCbUHwbdiGm4YmplhvwiWRiTFDL9hyyLOL1cddtoMHZLm3cUP87d2nGIINQJoRHQTWuOp8UsgHJ6eNZ6E62WsYeTQIDAQAB";
      }
      # AhaSend
      {
        recordType = "TXT";
        name = "ahasend._domainkey";
        contents = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqRA74/KFh5TJqHCUaOJBTSQ1UbBUIeOY0LSjmSeFMWYnYfnXOaJgbHRGkSDi/SdCwW05M276B5g7kZKEpfvO0cFnHu6Olk806YaBj2zx8WG3tdH70YdGllY00EZbJPER9s/kY5CuCY1IiNkPsECasI6GIA5BtvCzdV8YtcyCKDb78ACEwY8TZrvEbgmxUMppp50JK1VR8xtvCs0yqg/ewyXsOVcpeGBNkpqtwmaXa3mNC491aHtVQqyT0+Zgjm4XmqJPKSY4qT/m6QoKCZgR6z64nw0Lzn6e+pPbRiYmMY39R5VZZgBR3mjHiCsfycI7ZVGRtHKjwObjF5ZcalAe7wIDAQAB";
      }
      {
        recordType = "CNAME";
        name = "psrp";
        target = "rp.ahasend.com.";
        ttl = "1h";
      }
      {
        recordType = "CNAME";
        name = "t";
        target = "track.ahasend.com.";
        ttl = "1h";
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
        target = "v-ps-sea";
      }
      {
        recordType = "SRV";
        name = "_sip._tcp";
        priority = 0;
        weight = 0;
        port = 5060;
        target = "v-ps-sea";
      }
      {
        recordType = "SRV";
        name = "_sips._tcp";
        priority = 0;
        weight = 0;
        port = 5061;
        target = "v-ps-sea";
      }
    ];
  };
}
