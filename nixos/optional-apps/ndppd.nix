_: {
  services.ndppd.enable = true;
  systemd.services.ndppd.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };
}
