{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  environment.systemPackages = [ config.services.fail2ban.package ];

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    banaction = if LT.this.openvz then "iptables-multiport" else "nftables-multiport";
    banaction-allports = if LT.this.openvz then "iptables-allports" else "nftables-allports";
    packageFirewall = if LT.this.openvz then pkgs.iptables-legacy else pkgs.nftables;
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
