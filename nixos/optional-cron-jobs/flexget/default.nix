{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
let

  nexusphpPlugin = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Juszoe/flexget-nexusphp/master/nexusphp.py";
    sha256 = "0shbdx2z7dn9bn08y4y2fpxdd2281nr7ifqr31bxarmk57srdlxm";
  };

  flexgetTemplate = pkgs.writeText "flexget.yml" (
    builtins.toJSON {
      templates = {
        downloads = {
          transmission = {
            path = "/mnt/storage/downloads";
            host = LT.this.ltnet.IPv4;
            port = LT.port.Transmission;
            bandwidth_priority = 0;
          };
          free_space = {
            path = "/mnt/storage/downloads";
            space = 2 * 1024 * 1024; # 2TB
          };
        };
        downloads-auto = {
          transmission = {
            path = "/mnt/ssd-temp/.downloads-auto";
            host = LT.this.ltnet.IPv4;
            port = LT.port.Transmission;
            bandwidth_priority = 0 - 1;
          };
          free_space = {
            path = "/mnt/ssd-temp/.downloads-auto";
            space = 200 * 1024; # 200GB
          };
        };
      };

      tasks = {
        remove-old-torrents = {
          from_transmission = {
            host = LT.this.ltnet.IPv4;
            port = LT.port.Transmission;
          };
          disable = [
            "seen"
            "seen_info_hash"
          ];
          "if" = [
            { "'No space left on device' in transmission_errorString" = "accept"; }
            { "'torrent not registered with this tracker' in transmission_errorString" = "accept"; }
            { "transmission_date_added < now - timedelta(days=5)" = "accept"; }
            {
              "transmission_progress < 100 and transmission_date_added < now - timedelta(hours=36)" = "accept";
            }
          ];
          regexp = {
            reject_excluding = [ "/mnt/ssd-temp/.downloads-auto" ];
            from = "transmission_downloadDir";
          };
          transmission = {
            host = LT.this.ltnet.IPv4;
            port = LT.port.Transmission;
            action = "purge";
          };
        };

        hdhome-auto = {
          limit = {
            amount = 1;
            from.rss = "$HDHOME_AUTO_RSS_URL";
          };
          seen.fields = [ "url" ];
          accept_all = true;
          template = "downloads-auto";
        };
      };
    }
  );

  flexget-override = lib.hiPrio (
    pkgs.runCommand "flexget-override" { nativeBuildInputs = with pkgs; [ makeWrapper ]; } ''
      mkdir -p $out/bin
      for F in ${pkgs.flexget}/bin/*; do
        makeWrapper \
          "$F" \
          $out/bin/$(basename "$F") \
          --add-flags "-c" \
          --add-flags "/var/lib/flexget/flexget.yml"
      done
    ''
  );
in
{
  age.secrets.flexget-env.file = inputs.secrets + "/flexget-env.age";

  environment.systemPackages = [ flexget-override ];

  systemd.services.flexget-runner = {
    wants = [
      "flaresolverr.service"
      "podman-byparr.service"
    ];
    after = [
      "network.target"
      "flaresolverr.service"
      "podman-byparr.service"
    ];

    environment = {
      FLARESOLVERR_URL = "http://127.0.0.1:${LT.portStr.FlareSolverr}";
      PROWLARR_URL = "http://127.0.0.1:${LT.portStr.Prowlarr}";
    };
    serviceConfig = LT.serviceHarden // {
      EnvironmentFile = config.age.secrets.flexget-env.path;
      Type = "oneshot";
      TimeoutSec = 3600;
      StateDirectory = "flexget";
      WorkingDirectory = "/var/lib/flexget";
    };
    script = ''
      cat ${flexgetTemplate} | ${pkgs.envsubst}/bin/envsubst > flexget.yml

      mkdir -p plugins
      ln -sf ${nexusphpPlugin} plugins/nexusphp.py

      ${pkgs.flexget}/bin/flexget -c flexget.yml backlog clear
      ${pkgs.flexget}/bin/flexget -c flexget.yml failed clear
      exec ${pkgs.flexget}/bin/flexget -c flexget.yml execute
    '';
  };

  systemd.timers.flexget-runner = {
    wantedBy = [ "timers.target" ];
    partOf = [ "flexget-runner.service" ];
    timerConfig = {
      OnCalendar = "*:0/10";
      RandomizedDelaySec = "5min";
      Unit = "flexget-runner.service";
    };
  };
}
