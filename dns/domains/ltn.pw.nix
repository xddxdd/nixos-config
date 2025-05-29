{ config, lib, ... }:
{
  domains = [
    rec {
      domain = "ltn.pw";
      registrar = "porkbun";
      providers = [ "gcore" ];
      dnssec = true;
      records = lib.flatten [
        {
          recordType = "fakeALIAS";
          name = "@";
          target = "terrahost";
          ttl = "10m";
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
          name = "pb.${domain}.";
          target = "hetzner-de.ltn.pw.";
          ttl = "10m";
        }
        {
          recordType = "CNAME";
          name = "pl.${domain}.";
          target = "xddxdd.duckdns.org.";
          ttl = "10m";
        }
        {
          recordType = "CNAME";
          name = "www";
          target = "terrahost.ltn.pw.";
          ttl = "10m";
        }

        config.common.hostRecs.CAA
        (config.common.hostRecs.Normal "${domain}.")
        (config.common.records.Autoconfig "${domain}.")
        config.common.records.Email
        config.common.records.Libravatar
        config.common.records.ProxmoxCluster
        config.common.records.SIP
        (config.common.hostRecs.LTNet "ltnet.${domain}.")
        (config.common.hostRecs.DN42 "dn42.${domain}.")
        (config.common.hostRecs.NeoNetwork "neo.${domain}.")
      ];
    }
  ];
}
