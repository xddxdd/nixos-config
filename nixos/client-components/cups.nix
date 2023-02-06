{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  services.printing = {
    enable = true;
    startWhenNeeded = false;
    drivers = with pkgs; [
      brgenml1cupswrapper
      brgenml1lpr
      brlaser
      cnijfilter2
      epson-escpr
      foomatic-db
      foomatic-db-engine
      foomatic-db-nonfree
      foomatic-db-ppds-withNonfreeDb
      foomatic-filters
      gutenprint
      gutenprintBin
      hplip
      hplipWithPlugin
      samsung-unified-linux-driver
      splix
    ];

    browsedConf = ''
      CreateIPPPrinterQueues All
    '';

    cups-pdf = {
      enable = true;
      instances.cups-pdf = {
        installPrinter = true;
        settings.Out = "/var/lib/cups-pdf";
      };
    };
  };

  services.system-config-printer.enable = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/cups-pdf 755 root root"
  ];
}
