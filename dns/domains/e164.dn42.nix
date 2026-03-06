{
  config,
  lib,
  ...
}:
{
  domains = [
    rec {
      domain = "7.4.5.2.0.4.2.4.e164.dn42";
      providers = [ "bind" ];
      records = lib.flatten [
        config.common.nameservers.DN42

        {
          recordType = "NAPTR";
          name = "*";
          order = 100;
          preference = 10;
          terminalFlag = "u";
          service = "E2U+sip";
          regexp = "!^(.*)$!sip:\\1@${config.common.records.SIPTarget}.lantian.dn42:5060!";
          target = ".";
        }
      ];
    }
  ];
}
