{ config, lib, ... }:
let
  homeDdnsTarget = "lantian.dns.army.";

  externalServices = [
    {
      recordType = "TXT";
      name = "@";
      contents = "google-site-verification=dFXi0jyD7Qm4WrRUaC79-XQWAJ4UwcdNSbGNTI9IvLg";
    }
  ];

  internalServices = [
    {
      recordType = "CNAME";
      name = "ai";
      target = homeDdnsTarget;
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "alert";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "asf";
      target = homeDdnsTarget;
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "attic";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "books";
      target = homeDdnsTarget;
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
      name = "cal";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "dashboard";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "immich";
      target = homeDdnsTarget;
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "jellyfin";
      target = homeDdnsTarget;
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
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "prometheus";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "rss";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "rsshub";
      target = "colocrossing.ltnet.xuyh0120.win.";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "rsync-ci";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "searx";
      target = "lt-home-vm.ltnet.xuyh0120.win.";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "stable-diffusion";
      target = "lt-home-vm.ltnet.xuyh0120.win.";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "stats";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "tachidesk";
      target = homeDdnsTarget;
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
      dnssec = true;
      records = lib.flatten [
        # ALIAS record cannot coexist with HTTPS on Gcore
        {
          recordType = "fakeALIAS";
          name = "@";
          target = "bwg-lax";
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
          name = "www";
          target = "@";
          ttl = "5m";
        }

        config.common.hostRecs.CAA
        (config.common.hostRecs.Normal "${domain}.")
        (config.common.records.Autoconfig "${domain}.")
        config.common.records.Email
        {
          recordType = "CNAME";
          name = "9z8suy0Sua6PUg8hDvxoxUvlkvbNx6MW._domainkey";
          target = "9z8suy0Sua6PUg8hDvxoxUvlkvbNx6MW.xuyh0120.win.dkim.nrt1.oracleemaildelivery.com.";
        }
        {
          recordType = "TXT";
          name = "ahasend._domainkey";
          contents = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvSKR1rbMOHc9M9kBQiSjf16UbHhEmKGRWKfMEvySVGGJhOeJ8svudF5VWPZ6pR6YnQeyCuuWnhyQ5ibrgg94zJD5TIojNOt8alJ1ZXk1asj2CPzI/6gzJjnrJXEfQdHkaTZCtLZjmgVqOkFPl0mZpKrhJMyaTh1z/MHnJ0qFCmZIsuu+j+V11hcGfgThtEehtqM0lp7s72OVqEgNOEkZW4KZQN6VxKDGSoRJirAREkiHJ4A9OYlLI24HHKZtA7N3YpC1ac/Z5nqLsj9EunfJMmS/JyReXtR6L8SJ5hZqoag6nlOAao1PSg5uVQ4ZjNgsj/zYjSnlu0FbM6Jk3ksjZwIDAQAB";
        }
        {
          recordType = "TXT";
          name = "_token._dnswl";
          contents = "qcq5l789ndevk0jawrgcah0f5s4ld8sz";
        }
        config.common.records.Libravatar
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
