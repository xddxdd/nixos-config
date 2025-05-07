_:
let
  cfg = ''
    LogColor=yes
    StatusUnitFormat=combined
  '';
in
{
  systemd.extraConfig = cfg;
  boot.initrd.systemd.extraConfig = cfg;
}
