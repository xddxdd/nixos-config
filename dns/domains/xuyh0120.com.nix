{ config, lib, ... }:
{
  domains = [
    rec {
      domain = "xuyh0120.com";
      providers = [ "henet" ];
      records = lib.flatten [
        {
          recordType = "ALIAS";
          name = "@";
          target = config.common.records.GeoDNSTarget;
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
          target = config.common.records.GeoDNSTarget;
          ttl = "10m";
        }

        config.common.hostRecs.CAA
        (config.common.hostRecs.Normal "${domain}.")
        (config.common.hostRecs.SSHFP "${domain}.")
        (config.common.records.Autoconfig "${domain}.")
        config.common.records.Email
        {
          recordType = "TXT";
          name = "ahasend._domainkey";
          contents = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwEANYIAC3jG+nRIYQCZXfBRaodoTHHsy5qUD6X7RGfR0B6AHWVGzX+n8/7tmoF1RCd2o9q2/tuLIL4RnztbHBANdpv5HKFl6KrNleJwTxJmo99xOydSIMw+YNbIK4mG4RZAjso+xuZTeiswsFY3MR4jF0K2vy4TdUWMkGrkrHF2rqVbdpKa2kZc4AX/qtdaxhdtrJM3NUEixXO3u9TQzJbXQbeOx5qDSVqDbzlPIUZ6aAtA+/TM8p/u2vk/QdQhHBB9yDXZItjoobNseyI4amYIsf0UpYSCUJ7RIKOBsT/Q+NXS5tqYZmKpnaL+JNXUB3qh3MBuv6wI4KC+WzM5JLwIDAQAB";
        }
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
