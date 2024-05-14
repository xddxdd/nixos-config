{ pkgs, ... }:
let
  cdemuDBusService = pkgs.stdenv.mkDerivation {
    pname = "cdemu-dbus-service";
    version = "1.0.0";
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/share/dbus-1/services
      cat >$out/share/dbus-1/services/net.sf.cdemu.CDEmuDaemon.service <<EOF
      [D-BUS Service]
      Name=net.sf.cdemu.CDEmuDaemon
      SystemdService=cdemu-daemon.service
      Exec=${pkgs.coreutils}/bin/true
      EOF
    '';
  };
in
{
  programs.cdemu = {
    enable = true;
    group = "wheel";
    gui = true;
    image-analyzer = true;
  };

  services.dbus.packages = [ cdemuDBusService ];

  systemd.user.services.cdemu-daemon = {
    serviceConfig = {
      Type = "dbus";
      BusName = "net.sf.cdemu.CDEmuDaemon";
      ExecStart = "${pkgs.cdemu-daemon}/bin/cdemu-daemon --config-file \"%h/.config/cdemu-daemon\"";
      Restart = "no";
    };
  };
}
