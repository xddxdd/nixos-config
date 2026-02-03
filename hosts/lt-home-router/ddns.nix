{ config, inputs, ... }:
{
  age.secrets.ddns-duckdns = {
    file = inputs.secrets + "/ddns/duckdns.age";
    owner = config.services.inadyn.user;
    inherit (config.services.inadyn) group;
  };
  age.secrets.ddns-dynv6 = {
    file = inputs.secrets + "/ddns/dynv6.age";
    owner = config.services.inadyn.user;
    inherit (config.services.inadyn) group;
  };
  age.secrets.ddns-tunnelbroker = {
    file = inputs.secrets + "/ddns/tunnelbroker.age";
    owner = config.services.inadyn.user;
    inherit (config.services.inadyn) group;
  };

  services.inadyn = {
    enable = true;
    interval = "hourly";
    settings = {
      allow-ipv6 = true;
      period = 1;
      forced-update = 1;
      provider = {
        "default@duckdns.org" = {
          hostname = "xddxdd.duckdns.org";
          include = config.age.secrets.ddns-duckdns.path;
        };
        "default@ipv4.dynv6.com" = {
          hostname = "lantian.dns.army";
          include = config.age.secrets.ddns-dynv6.path;
        };
        "default@tunnelbroker.net" = {
          hostname = "897326";
          include = config.age.secrets.ddns-tunnelbroker.path;
        };
      };
    };
  };
}
