{ config, inputs, ... }:
{
  sops.secrets.ddns-duckdns-key.sopsFile = inputs.secrets + "/ddns.yaml";
  sops.secrets.ddns-dynv6-key.sopsFile = inputs.secrets + "/ddns.yaml";
  sops.secrets.ddns-tunnelbroker-key.sopsFile = inputs.secrets + "/ddns.yaml";

  sops.templates.ddns-duckdns = {
    content = ''
      username = "${config.sops.placeholder.ddns-duckdns-key}"
      password = "unused"
    '';
    owner = config.services.inadyn.user;
    inherit (config.services.inadyn) group;
  };
  sops.templates.ddns-dynv6 = {
    content = ''
      username = "${config.sops.placeholder.ddns-dynv6-key}"
      password = "unused"
    '';
    owner = config.services.inadyn.user;
    inherit (config.services.inadyn) group;
  };
  sops.templates.ddns-tunnelbroker = {
    content = ''
      username = "xddxdd"
      password = "${config.sops.placeholder.ddns-tunnelbroker-key}"
    '';
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
          include = config.sops.templates.ddns-duckdns.path;
        };
        "default@ipv4.dynv6.com" = {
          hostname = "lantian.dns.army";
          include = config.sops.templates.ddns-dynv6.path;
        };
        "default@tunnelbroker.net" = {
          hostname = "897326";
          include = config.sops.templates.ddns-tunnelbroker.path;
        };
      };
    };
  };
}
