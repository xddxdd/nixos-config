{ pkgs, config, ... }:

let
  LT = import ../helpers.nix { inherit config pkgs; };

  lgproxyHosts = [
    "50kvm"
    "hostdare"
    "virmach-ny1g"
    "buyvm"
  ];
  lgproxyDomain = "bird-lg-go";
in
{
  networking.hosts = builtins.listToAttrs
    ((builtins.map
      (n: {
        name = LT.hosts.${n}.ltnet.IPv4;
        value = [ "${n}.${lgproxyDomain}" ];
      })
      lgproxyHosts)
    ++ [{
      name = LT.this.ltnet.IPv4;
      value = [ "local.${lgproxyDomain}" ];
    }]);

  systemd.services.bird-lg-go = {
    description = "Bird-lg-go";
    wantedBy = [ "multi-user.target" ];
    environment = {
      BIRDLG_DNS_INTERFACE = "asn.lantian.dn42";
      BIRDLG_DOMAIN = lgproxyDomain;
      BIRDLG_LISTEN = "127.0.0.1:${LT.portStr.BirdLgGo}";
      BIRDLG_NAME_FILTER = "^(sys|static)_";
      BIRDLG_NET_SPECIFIC_MODE = "dn42_shorten";
      BIRDLG_SERVERS = builtins.concatStringsSep "," (lgproxyHosts ++ [ "local" ]);
      BIRDLG_TELEGRAM_BOT_NAME = "lantian_lg_bot";
      BIRDLG_WHOIS = "172.22.76.108";
    };
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.bird-lg-go}/bin/frontend";
      DynamicUser = true;
    };
  };

  services.nginx.virtualHosts = {
    "lg.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.BirdLgGo}";
          extraConfig = LT.nginx.locationBlockUserAgentConf
            + LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
    "lg.lantian.dn42" = {
      listen = LT.nginx.listenHTTP;
      serverAliases = [ "lg.lantian.neo" ];
      locations = LT.nginx.addCommonLocationConf {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.BirdLgGo}";
          extraConfig = LT.nginx.locationBlockUserAgentConf
            + LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.makeSSL "lantian.dn42_ecc"
        + LT.nginx.commonVhostConf true;
    };
  };
}
