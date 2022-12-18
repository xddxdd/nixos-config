{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      brgenml1cupswrapper
      brgenml1lpr
      brlaser
      cnijfilter2
      epson-escpr
      gutenprint
      gutenprintBin
      hplip
      hplipWithPlugin
      samsung-unified-linux-driver
      splix
    ];
  };

  services.system-config-printer.enable = true;
}
