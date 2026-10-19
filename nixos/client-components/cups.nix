{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  lantian.firewall.presets.public-firewall.firewalledPorts =
    lib.mkIf config.services.printing.enable
      [ LT.port.CUPS ];

  services.printing = {
    enable = true;
    startWhenNeeded = false;
    drivers = with pkgs; [
      brgenml1cupswrapper
      brgenml1lpr
      brlaser
      # cnijfilter2
      # epson-escpr
      foomatic-db
      foomatic-db-engine
      foomatic-db-nonfree
      foomatic-db-ppds-withNonfreeDb
      foomatic-filters
      gutenprint
      gutenprintBin
      hplip
      hplipWithPlugin
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

  # Note: cupsd is deliberately NOT hardened: it spawns printer filter and
  # driver helper binaries (cups-driverd aborts with EPERM 101 under any
  # hardening key set), so it is exempted in ensure-service-harden along with
  # cups-browsed. Only restart + writable dirs are configured here.
  systemd.services.cups.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "3";
    ReadWritePaths = [
      "/etc/cups"
      "/var/cache/cups"
      "/var/spool/cups"
      "/var/lib/cups"
      "/var/lib/cups-pdf"
    ];
  };

  systemd.tmpfiles.settings.cups = {
    "/var/cache/cups"."d" = { mode = "0700"; user = "root"; group = "root"; };
    "/var/spool/cups"."d" = { mode = "0700"; user = "root"; group = "root"; };
    "/var/lib/cups"."d" = { mode = "0700"; user = "root"; group = "root"; };
  };

  systemd.services.cups-browsed.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "3";
  };

  systemd.tmpfiles.settings = {
    cups-pdf = {
      "/var/lib/cups-pdf"."d" = {
        mode = "755";
        user = "root";
        group = "root";
      };
    };
  };
}
