{ pkgs, lib, config, ... }:

{
  boot.loader = {
    grub = {
      enable = true;
      default = "saved";
      version = 2;
      splashImage = null;
      font = lib.mkDefault
        "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF.ttf";
      fontSize = lib.mkDefault 16;
    };
  };

  console.earlySetup = true;

  systemd.services.systemd-sysctl.serviceConfig = {
    ExecStart = [
      ""
      "/bin/sh -c \"${pkgs.systemd}/lib/systemd/systemd-sysctl; exit 0\""
    ];
  };
}
