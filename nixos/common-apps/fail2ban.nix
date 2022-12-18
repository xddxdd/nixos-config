{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  environment.systemPackages = [ config.services.fail2ban.package ];

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    banaction = "nftables-multiport";
    banaction-allports = "nftables-allports";
    packageFirewall = pkgs.nftables-fullcone;
    ignoreIP = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.0.0.0/24"
      "192.0.2.0/24"
      "192.168.0.0/16"
      "198.18.0.0/15"
      "198.51.100.0/24"
      "203.0.113.0/24"
      "240.0.0.0/4"
      "fc00::/7"
    ];

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
