{ config, inputs, ... }:
{
  age.secrets.searxng-env = {
    file = inputs.secrets + "/searxng-env.age";
    owner = "searx";
    group = "searx";
  };

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    runInUwsgi = true;
    uwsgiConfig = {
      disable-logging = true;
      socket = "/run/searx/searx.sock";
      chmod-socket = "660";
    };
    environmentFile = config.age.secrets.searxng-env.path;
    settings = {
      server.secret_key = "@SEARX_SERVER_SECRET_KEY@";
      search = {
        formats = [
          "html"
          "csv"
          "json"
          "rss"
        ];
      };
    };
  };

  systemd.services.uwsgi = {
    after = [ "redis-searx.service" ];
    requires = [ "redis-searx.service" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };
  };

  users.groups.searx.members = [ "nginx" ];

  lantian.nginxVhosts."searx.xuyh0120.win" = {
    locations = {
      "/".extraConfig = ''
        uwsgi_pass unix:/run/searx/searx.sock;
      '';
    };

    sslCertificate = "lets-encrypt-xuyh0120.win";
    noIndex.enable = true;
  };
}
