_:
let
  settings = {
    LogColor = true;
    StatusUnitFormat = "combined";
  };
in
{
  systemd.settings.Manager = settings;
  boot.initrd.systemd.settings.Manager = settings;
}
