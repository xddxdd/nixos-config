{ LT, ... }:
{
  services.quassel = {
    enable = true;
    dataDir = "/var/lib/quassel";
    interfaces = [
      "0.0.0.0"
      "::"
    ];
    portNumber = LT.port.Quassel;
  };

  systemd.services.quassel.serviceConfig = LT.serviceHarden // {
    StateDirectory = "quassel";
    MemoryDenyWriteExecute = false;
  };
}
