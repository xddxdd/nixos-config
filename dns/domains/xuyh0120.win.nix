{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
}@args:
let
  externalServices = [
    {
      recordType = "TXT";
      name = "@";
      contents = "google-site-verification=dFXi0jyD7Qm4WrRUaC79-XQWAJ4UwcdNSbGNTI9IvLg";
    }

    {
      recordType = "CNAME";
      name = "s1._domainkey";
      target = "s1.domainkey.u6126456.wl207.sendgrid.net.";
    }
    {
      recordType = "CNAME";
      name = "s2._domainkey";
      target = "s2.domainkey.u6126456.wl207.sendgrid.net.";
    }
    {
      recordType = "CNAME";
      name = "em3816";
      target = "u6126456.wl207.sendgrid.net.";
    }
    {
      recordType = "CNAME";
      name = "url9203";
      target = "sendgrid.net.";
    }
    {
      recordType = "CNAME";
      name = "6126456";
      target = "sendgrid.net.";
    }
  ];

  internalServices = [
    {
      recordType = "CNAME";
      name = "alert";
      target = "terrahost";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "asf";
      target = "terrahost";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "attic";
      target = "v-ps-fal";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "books";
      target = "lt-home-vm.ltnet.xuyh0120.win.";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "bitwarden";
      target = "terrahost";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "cloud";
      target = "terrahost";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "dashboard";
      target = "terrahost";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "jellyfin";
      target = "lt-home-vm.ltnet.xuyh0120.win.";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "lab";
      target = "lab.lantian.pub.";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "netbox";
      target = "v-ps-fal";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "private";
      target = "v-ps-fal.ltnet.xuyh0120.win.";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "prometheus";
      target = "terrahost";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "pterodactyl";
      target = "lt-home-vm.ltnet.xuyh0120.win.";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "rss";
      target = "v-ps-fal";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "rsshub";
      target = "v-ps-fal.ltnet.xuyh0120.win.";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "stats";
      target = "v-ps-fal";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "tachidesk";
      target = "lt-home-vm.ltnet.xuyh0120.win.";
      ttl = "1h";
    }
  ];
in
{
  domains = [
    rec {
      domain = "xuyh0120.win";
      registrar = "porkbun";
      providers = [ "gcore" ];
      records = lib.flatten [
        {
          recordType = "ALIAS";
          name = "@";
          target = "lantian.pub.";
          ttl = "5m";
        }
        {
          recordType = "CNAME";
          name = "www";
          target = "@";
          ttl = "5m";
        }

        config.common.hostRecs.CAA
        (config.common.hostRecs.Normal "${domain}.")
        (config.common.records.Autoconfig "${domain}.")
        config.common.records.MXRoute
        {
          recordType = "TXT";
          name = "_token._dnswl";
          contents = "qcq5l789ndevk0jawrgcah0f5s4ld8sz";
        }
        config.common.records.Libravatar
        config.common.records.ProxmoxCluster
        config.common.records.SIP
        (config.common.hostRecs.LTNet "ltnet.${domain}.")
        (config.common.hostRecs.DN42 "dn42.${domain}.")
        (config.common.hostRecs.NeoNetwork "neo.${domain}.")

        externalServices
        internalServices
      ];
    }
  ];
}
