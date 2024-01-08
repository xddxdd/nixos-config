{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
} @ args: {
  domains = [
    rec {
      domain = "ltn.pw";
      registrar = "porkbun";
      providers = ["cloudflare"];
      records = lib.flatten [
        {
          recordType = "ALIAS";
          name = "${domain}.";
          target = "terrahost.ltn.pw.";
          ttl = "10m";
        }
        {
          recordType = "CNAME";
          name = "pb.${domain}.";
          target = "v-ps-fal.ltn.pw.";
          ttl = "10m";
        }
        {
          recordType = "CNAME";
          name = "www.${domain}.";
          target = "terrahost.ltn.pw.";
          ttl = "10m";
        }

        config.common.hostRecs.CAA
        (config.common.hostRecs.Normal domain)
        (config.common.hostRecs.SSHFP domain)
        (config.common.records.Autoconfig domain)
        config.common.records.MXRoute
        config.common.records.Libravatar
        config.common.records.ProxmoxCluster
        config.common.records.SIP
        config.common.records.GeoRecords
        (config.common.hostRecs.LTNet "ltnet.${domain}")
        (config.common.hostRecs.DN42 "dn42.${domain}")
        (config.common.hostRecs.NeoNetwork "neo.${domain}")
      ];
    }
  ];
}
