{ pkgs, config, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  systemd.services.bird-lg-go = {
    description = "Bird-lg-go";
    wantedBy = [ "multi-user.target" ];
    environment = {
      BIRDLG_LISTEN = "${thisHost.ltnet.IPv4Prefix}.1:13180";
      BIRDLG_SERVERS = "50kvm,hostdare,virmach-ny1g,virtono";
      BIRDLG_DOMAIN = "zt.lantian.pub";
      BIRDLG_WHOIS = "172.22.76.108";
      BIRDLG_DNS_INTERFACE = "asn.lantian.dn42";
      BIRDLG_NET_SPECIFIC_MODE = "dn42_shorten";
      BIRDLG_TELEGRAM_BOT_NAME = "lantian_lg_bot";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur.repos.xddxdd.bird-lg-go}/bin/frontend";
    };
  };
}
