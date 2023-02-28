{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  environment.etc = {
    "fail2ban/action.d/nftables-lantian.conf".source = lib.mkForce ./action.d/nftables-lantian.conf;
    "fail2ban/filter.d/asterisk-lantian.conf".source = lib.mkForce ./filter.d/asterisk-lantian.conf;
  };
  environment.systemPackages = [config.services.fail2ban.package];

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    banaction = "nftables-lantian[type=allports]";
    banaction-allports = "nftables-lantian[type=allports]";
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
