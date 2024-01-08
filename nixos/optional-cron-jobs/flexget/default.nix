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
    wants = ["flaresolverr.service"];
    after = ["network.target" "flaresolverr.service"];

    environment = {
      FLARESOLVERR_IP_PORT = "127.0.0.1:${LT.portStr.FlareSolverr}";
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
    script = ''
      export OURBITS_TOKEN=$(${py}/bin/python3 ${./ourbits_login.py})
      cat ${flexgetTemplate} | ${pkgs.envsubst}/bin/envsubst > flexget.yml
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
