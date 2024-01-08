{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  py = pkgs.python3.withPackages (p:
    with p; [
      requests
    ]);

  nexusphpPlugin = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Juszoe/flexget-nexusphp/master/nexusphp.py";
    sha256 = "0shbdx2z7dn9bn08y4y2fpxdd2281nr7ifqr31bxarmk57srdlxm";
  };

  flexgetTemplate = pkgs.writeText "flexget.yml" (builtins.toJSON {
    templates = {
      downloads.transmission = {
        path = "/mnt/storage/downloads";
        host = LT.this.ltnet.IPv4;
        port = LT.port.Transmission;
        bandwidth_priority = 0;
      };
      downloads-auto.transmission = {
        path = "/mnt/storage/.downloads-auto";
        host = LT.this.ltnet.IPv4;
        port = LT.port.Transmission;
        bandwidth_priority = 0 - 1;
      };
    };

    tasks = {
      remove-old-torrents = {
        from_transmission = {
          host = LT.this.ltnet.IPv4;
          port = LT.port.Transmission;
        };
        disable = ["seen" "seen_info_hash"];
        accept_all = true;
        "if" = [{"transmission_date_added > now - timedelta(days=5)" = "reject";}];
        regexp = {
          reject_excluding = ["/mnt/storage/.downloads-auto"];
          from = "transmission_downloadDir";
        };
        transmission = {
          host = LT.this.ltnet.IPv4;
          port = LT.port.Transmission;
          action = "purge";
        };
      };

      hdtime-auto = {
        rss = {
          url = "$HDTIME_AUTO_RSS_URL";
          other_fields = ["link"];
        };
        nexusphp = {
          cookie = "$HDTIME_COOKIE";
          discount = ["free" "2xfree"];
          left-time = "1 hours";
          hr = false;
          remember = true;
        };
        cfscraper = true;
        template = "downloads-auto";
      };

      ourbits = {
        rss = "$OURBITS_RSS_URL";
        seen.fields = ["url"];
        accept_all = true;
        template = "downloads";
      };

      ourbits-auto = {
        rss = {
          url = "$OURBITS_AUTO_RSS_URL";
          other_fields = ["link"];
        };
        nexusphp = {
          cookie = "ourbits_jwt=$OURBITS_TOKEN";
          discount = ["free" "2xfree"];
          left-time = "1 hours";
          hr = false;
          remember = true;
        };
        cfscraper = true;
        template = "downloads-auto";
      };
    };
  });
in {
  age.secrets.flexget-env.file = inputs.secrets + "/flexget-env.age";

  environment.systemPackages = [pkgs.flexget];

  systemd.services.flexget-runner = {
    requires = ["flaresolverr.service"];
    after = ["network.target" "flaresolverr.service"];

    environment = {
      FLARESOLVERR_URL = "http://127.0.0.1:${LT.portStr.FlareSolverr}";
      PROWLARR_URL = "http://127.0.0.1:${LT.portStr.Prowlarr}";
    };
    serviceConfig =
      LT.serviceHarden
      // {
        EnvironmentFile = config.age.secrets.flexget-env.path;
        Type = "oneshot";
        TimeoutSec = 3600;
        StateDirectory = "flexget";
        WorkingDirectory = "/var/lib/flexget";
      };
    script =
      ''
        export HDTIME_COOKIE=$(${py}/bin/python3 ${./hdtime_login.py})
        export OURBITS_TOKEN=$(${py}/bin/python3 ${./ourbits_login.py})
      ''
      + (lib.optionalString config.services.prowlarr.enable ''
        ${py}/bin/python3 ${./ourbits_update_prowlarr.py}
      '')
      + ''
        cat ${flexgetTemplate} | ${pkgs.envsubst}/bin/envsubst > flexget.yml

        mkdir -p plugins
        ln -sf ${nexusphpPlugin} plugins/nexusphp.py

        exec ${pkgs.flexget}/bin/flexget -c flexget.yml execute
      '';
  };

  systemd.timers.flexget-runner = {
    wantedBy = ["timers.target"];
    partOf = ["flexget-runner.service"];
    timerConfig = {
      OnCalendar = "*:0/10";
      RandomizedDelaySec = "5min";
      Unit = "flexget-runner.service";
    };
  };
}
