{ config, lib, LT, ... }: {
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    fangfrisch = {
      enable = true;
      settings = {
        interserver.enabled = "yes";
        sanesecurity.enabled = "yes";
        urlhaus.enabled = "yes";
      };
    };
  };

  systemd.services.clamav-daemon.serviceConfig = LT.serviceHarden // {
    Restart = "always";
    RestartSec = 5;
    # confinement chroot: bind the generated config read-only
    BindReadOnlyPaths = [
      "${config.environment.etc."clamav/clamd.conf".source}:/etc/clamav/clamd.conf"
    ];
  };
  lantian.harden.clamav-daemon = true;
  systemd.services.clamav-freshclam.requires = [ "network-online.target" ];
  systemd.services.clamav-fangfrisch.requires = [ "network-online.target" ];
}
