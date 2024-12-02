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

  users.groups.searx.members = [ "nginx" ];

  lantian.nginxVhosts."searx.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/".extraConfig = ''
        uwsgi_pass unix:/run/searx/searx.sock;
      '';
    };

    sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
    noIndex.enable = true;
  };
}
