{
  pkgs,
  lib,
  LT,
  ...
}:
{
  systemd.services.nmea-static-gps-server = {
    description = "NMEA Static GPS Server";
    after = [
      "network.target"
      "avahi-daemon.service"
    ];
    wants = [ "avahi-daemon.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      NMEA_LAT = LT.this.city.lat;
      NMEA_LON = LT.this.city.lng;
      NMEA_ALT = "0";
      NMEA_PORT = LT.portStr.NMEA;
    };

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${lib.getExe pkgs.python3} ${LT.sources.nmea-static-gps-server.src}/nmea_server.py";

      Restart = "always";
      RestartSec = "5";
    };
  };

  # Announce NMEA service via mDNS so LAN clients can discover it
  services.avahi.extraServiceFiles = {
    nmea-static = ''
      <?xml version="1.0" standalone='no'?>
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name replace-wildcards="yes">NMEA GPS (%h)</name>
        <service>
          <type>_nmea-0183._tcp</type>
          <port>${LT.portStr.NMEA}</port>
        </service>
      </service-group>
    '';
  };
}
