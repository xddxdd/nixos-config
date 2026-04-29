{ pkgs, lib, ... }:
{
  boot.extraModprobeConfig = ''
    install algif_aead ${lib.getExe' pkgs.coreutils "false"}
  '';

  systemd.services.disable-algif-aead = {
    description = "Unload algif_aead module at boot";
    after = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "rmmod-algif-aead" ''
        ${pkgs.kmod}/bin/modprobe -r algif_aead 2>/dev/null || true
      ''}";
      RemainAfterExit = true;
    };
  };
}
