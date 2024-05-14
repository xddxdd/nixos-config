{ pkgs, LT, ... }:
{
  systemd.services.decluttarr = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "radarr.service"
      "sonarr.service"
    ];
    requires = [
      "radarr.service"
      "sonarr.service"
    ];

    environment = {
      # Use environment variables instead of config file
      IS_IN_DOCKER = "1";

      REMOVE_TIMER = "10";
      REMOVE_FAILED = "True";
      REMOVE_STALLED = "True";
      REMOVE_METADATA_MISSING = "True";
      # May delete media that can be manually imported
      REMOVE_ORPHANS = "False";
      # May break multi season download
      REMOVE_UNMONITORED = "False";
      REMOVE_MISSING_FILES = "True";
      REMOVE_SLOW = "False";
      PERMITTED_ATTEMPTS = "3";
      RADARR_URL = "http://127.0.0.1:${LT.portStr.Radarr}";
      SONARR_URL = "http://127.0.0.1:${LT.portStr.Sonarr}";
    };

    script = ''
      export RADARR_KEY=$(cat /var/lib/radarr/config.xml  | grep -E -o "[0-9a-f]{32}")
      export SONARR_KEY=$(cat /var/lib/sonarr/config.xml  | grep -E -o "[0-9a-f]{32}")
      exec ${pkgs.decluttarr}/bin/decluttarr
    '';

    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "5";

      User = "lantian";
      Group = "users";
    };
  };
}
