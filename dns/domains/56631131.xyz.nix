{ config, lib, ... }:
{
  domains = [
    rec {
      domain = "56631131.xyz";
      registrar = "porkbun";
      providers = [ "gcore" ];
      dnssec = true;
      records = lib.flatten [
        config.common.hostRecs.CAA
        (config.common.hostRecs.Normal "${domain}.")
        config.common.records.Libravatar
        config.common.records.SIP
        (config.common.hostRecs.LTNet "ltnet.${domain}.")
        (config.common.hostRecs.DN42 "dn42.${domain}.")
        (config.common.hostRecs.NeoNetwork "neo.${domain}.")

        {
          recordType = "fakeALIAS";
          name = "@";
          target = "hetzner-de";
          ttl = "1h";
        }
        {
          recordType = "HTTPS";
          name = "@";
          priority = 1;
          target = ".";
          modifiers = "alpn=h3,h2";
        }
        {
          recordType = "CNAME";
          name = "www";
          target = "${domain}.";
        }

        {
          recordType = "NS";
          name = "virmach-host";
          target = "ns1.vp.net.co.";
        }
        {
          recordType = "NS";
          name = "virmach-host";
          target = "ns2.vp.net.co.";
        }

        {
          recordType = "NS";
          name = "xip";
          target = "ns-aws.sslip.io.";
        }
        {
          recordType = "NS";
          name = "xip";
          target = "ns-gce.sslip.io.";
        }
        {
          recordType = "NS";
          name = "xip";
          target = "ns-azure.sslip.io.";
        }

        {
          recordType = "NS";
          name = "dt";
          target = "bwg-lax.lantian.pub.";
        }

        {
          recordType = "TXT";
          name = "@";
          contents = "google-site-verification=LQvBzSL4-2NbbqM2208pYGLsRSw_hw132GGUvnShQGU";
        }
      ];
    }
  ];
}
