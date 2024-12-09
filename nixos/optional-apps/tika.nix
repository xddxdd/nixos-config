{ LT, ... }:
{
  services.tika = {
    enable = true;
    enableOcr = true;
    listenAddress = "127.0.0.1";
    port = LT.port.Tika;
  };
}
