{ config, inputs, ... }:
let
  enableBuiltinEngines =
    builtins.map
      (n: {
        name = n;
        disabled = false;
      })
      [
        "bing"
        "360search"
        "baidu"
        "quark"
        "sogou"
        "material icons"
        "bilibili"
        "sogou wechat"
        "apple maps"
        "crates.io"
        "lib.rs"
        "npm"
        "pkg.go.dev"
        "codeberg"
        "gitea.com"
        "gitlab"
        "huggingface"
        "huggingface datasets"
        "ollama"
        "sourcehut"
        "nixos wiki"
        "anaconda"
        "cppreference"
        "hackernews"
        "lobste.rs"
        "apk mirror"
        "fdroid"
        "google play apps"
        "1337x"
        "annas archive"
        "library genesis"
        "nyaa"
        "z-library"
        "imdb"
        "rottentomatoes"
        "tmdb"
        "minecraft wiki"
        "duckduckgo weather"
        "openmeteo"
        "openlibrary"
        "steam"
      ];
in
{
  age.secrets.searxng-env = {
    file = inputs.secrets + "/searxng-env.age";
    owner = "searx";
    group = "searx";
  };

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    configureUwsgi = true;
    uwsgiConfig = {
      disable-logging = true;
      socket = "/run/searx/searx.sock";
      chmod-socket = "660";
    };
    environmentFile = config.age.secrets.searxng-env.path;
    settings = {
      server.secret_key = "@SEARX_SERVER_SECRET_KEY@";
      search = {
        favicon_resolver = "duckduckgo";
        formats = [
          "html"
          "csv"
          "json"
          "rss"
        ];
      };
      engines = enableBuiltinEngines;
    };
    faviconsSettings = {
      favicons = {
        cfg_schema = 1;
        cache = {
          db_url = "/var/cache/searx/faviconcache.db";
          HOLD_TIME = 5184000;
          LIMIT_TOTAL_BYTES = 2147483648;
          BLOB_MAX_BYTES = 40960;
          MAINTENANCE_MODE = "auto";
          MAINTENANCE_PERIOD = 600;
        };
      };
    };
  };

  systemd.services.uwsgi = {
    after = [ "redis-searx.service" ];
    requires = [ "redis-searx.service" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
      CacheDirectory = "searx";
    };
  };

  users.groups.searx.members = [ "nginx" ];

  lantian.nginxVhosts."searx.xuyh0120.win" = {
    locations = {
      "/".extraConfig = ''
        uwsgi_pass unix:/run/searx/searx.sock;
      '';
    };

    sslCertificate = "zerossl-xuyh0120.win";
    noIndex.enable = true;
    accessibleBy = "private";
  };
}
