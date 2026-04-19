{ config, inputs, ... }:
{
  sops.secrets.ddns-duckdns = {
    sopsFile = inputs.secrets + "/ddns.yaml";
    owner = config.services.inadyn.user;
    inherit (config.services.inadyn) group;
  };
  sops.secrets.ddns-dynv6 = {
    sopsFile = inputs.secrets + "/ddns.yaml";
    owner = config.services.inadyn.user;
    inherit (config.services.inadyn) group;
  };
  sops.secrets.ddns-tunnelbroker = {
    sopsFile = inputs.secrets + "/ddns.yaml";
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
          include = config.sops.secrets.ddns-duckdns.path;
        };
        "default@ipv4.dynv6.com" = {
          hostname = "lantian.dns.army";
          include = config.sops.secrets.ddns-dynv6.path;
        };
        "default@tunnelbroker.net" = {
          hostname = "897326";
          include = config.sops.secrets.ddns-tunnelbroker.path;
        };
      };
    };
  };
}
