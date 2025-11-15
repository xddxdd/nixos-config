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

        # VirMach free host
        {
          recordType = "A";
          name = "virmach-host";
          address = "5.253.38.3";
        }

        # SSLIP.io
        {
          recordType = "NS";
          name = "xip";
          target = "ns-do-sg.sslip.io.";
        }
        {
          recordType = "NS";
          name = "xip";
          target = "ns-hetzner.sslip.io.";
        }
        {
          recordType = "NS";
          name = "xip";
          target = "ns-ovh.sslip.io.";
        }

        # MyOwnFreeHost
        {
          recordType = "NS";
          name = "mofh";
          target = "ns1.byet.org.";
        }
        {
          recordType = "NS";
          name = "mofh";
          target = "ns2.byet.org.";
        }
        {
          recordType = "NS";
          name = "mofh";
          target = "ns3.byet.org.";
        }
        {
          recordType = "NS";
          name = "mofh";
          target = "ns4.byet.org.";
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
