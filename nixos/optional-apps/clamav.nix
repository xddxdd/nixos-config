_: {
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    fangfrisch = {
      enable = true;
      settings = {
        interserver.enabled = "yes";
        sanesecurity.enabled = "yes";
        urlhaus.enabled = "yes";
      };
    };
  };

  systemd.services.clamav-daemon.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };
  systemd.services.clamav-freshclam.requires = [ "network-online.target" ];
  systemd.services.clamav-fangfrisch.requires = [ "network-online.target" ];
}
