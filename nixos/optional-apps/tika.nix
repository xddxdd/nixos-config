{ LT, ... }:
{
  services.tika = {
    enable = true;
    enableOcr = true;
    listenAddress = "127.0.0.1";
    port = LT.port.Tika;
  };

  systemd.services.tika.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };
}
