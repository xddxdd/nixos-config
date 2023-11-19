{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  lgproxyHosts = [
    "buyvm"
    "oracle-vm1"
    "v-ps-hkg"
    "v-ps-sjc"
    "virmach-ny1g"
  ];
  lgproxyDomain = "bird-lg-go";
in {
  networking.hosts =
    builtins.listToAttrs
    ((builtins.map
        (n: {
          name = LT.hosts.${n}.ltnet.IPv4;
          value = ["${n}.${lgproxyDomain}"];
        })
        lgproxyHosts)
      ++ [
        {
          name = LT.this.ltnet.IPv4;
          value = ["local.${lgproxyDomain}"];
        }
      ]);

  systemd.services.bird-lg-go = {
    description = "Bird-lg-go";
    wantedBy = ["multi-user.target"];
    environment = {
      BIRDLG_DNS_INTERFACE = "asn.lantian.dn42";
      BIRDLG_DOMAIN = lgproxyDomain;
      BIRDLG_LISTEN = "/run/bird-lg-go/bird-lg-go.sock";
      BIRDLG_NAME_FILTER = "^(ltdocker|sys_|static_|ltdyn_|ltnet_lantian_)";
      BIRDLG_NET_SPECIFIC_MODE = "dn42_shorten";
      BIRDLG_SERVERS = builtins.concatStringsSep "," (lgproxyHosts ++ ["local"]);
      BIRDLG_TELEGRAM_BOT_NAME = "lantian_lg_bot";
      BIRDLG_WHOIS = "172.22.76.108";
    };
    serviceConfig =
      LT.serviceHarden
      // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${pkgs.bird-lg-go}/bin/frontend";
        RuntimeDirectory = "bird-lg-go";
        User = "bird-lg-go";
        Group = "bird-lg-go";
        UMask = "007";
      };
  };

  services.nginx.virtualHosts = {
    "lg.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://unix:/run/bird-lg-go/bird-lg-go.sock";
          extraConfig =
            LT.nginx.locationBlockUserAgentConf
            + LT.nginx.locationProxyConf;
        };
      };
      extraConfig =
        LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
    "lg.lantian.dn42" = {
      listen = LT.nginx.listenHTTP;
      serverAliases = ["lg.lantian.neo"];
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://unix:/run/bird-lg-go/bird-lg-go.sock";
          extraConfig =
            LT.nginx.locationBlockUserAgentConf
            + LT.nginx.locationProxyConf;
        };
      };
      extraConfig =
        LT.nginx.makeSSL "lantian.dn42_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
  };

  users.users.bird-lg-go = {
    group = "bird-lg-go";
    isSystemUser = true;
  };
  users.groups.bird-lg-go.members = ["nginx"];
}
