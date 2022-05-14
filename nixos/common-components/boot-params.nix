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

    systemd-boot = {
      configurationLimit = 32;
      consoleMode = "max";
      editor = false;
      memtest86.enable = true;
      netbootxyz.enable = true;
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
