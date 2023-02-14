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

    cups-pdf = {
      enable = true;
      instances.cups-pdf = {
        installPrinter = true;
        settings.Out = "/var/lib/cups-pdf";
      };
    };
  };

  services.system-config-printer.enable = true;

  systemd.services.cups.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "3";
  };

  systemd.services.cups-browsed.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "3";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/cups-pdf 755 root root"
  ];
}
