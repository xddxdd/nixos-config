{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
}@args:
{
  domains = [
    rec {
      domain = "56631131.xyz";
      registrar = "porkbun";
      providers = [ "gcore" ];
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
          target = "v-ps-fal";
          ttl = "1h";
        }
        {
          recordType = "CNAME";
          name = "www";
          target = "${domain}.";
        }

        {
          recordType = "NS";
          name = "virmach-host";
          target = "ns1.vpshared.com.";
        }
        {
          recordType = "NS";
          name = "virmach-host";
          target = "ns2.vpshared.com.";
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
          recordType = "TXT";
          name = "@";
          contents = "google-site-verification=LQvBzSL4-2NbbqM2208pYGLsRSw_hw132GGUvnShQGU";
        }
      ];
    }
  ];
}
