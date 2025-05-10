_: {
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  systemd.services.clamav-daemon.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };
  systemd.services.clamav-freshclam.requires = [ "network-online.target" ];
}
