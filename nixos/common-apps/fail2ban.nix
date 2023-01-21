{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  environment.systemPackages = [ config.services.fail2ban.package ];

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    banaction = "nftables-multiport";
    banaction-allports = "nftables-allports";
    packageFirewall = pkgs.nftables-fullcone;
    ignoreIP = with LT.constants; (reserved.IPv4 ++ reserved.IPv6);

    daemonConfig = ''
      [DEFAULT]
      loglevel = NOTICE
      logtarget = SYSLOG
    '';

    bantime-increment = {
      enable = true;
      overalljails = true;
    };
  };
}
