{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  lgproxyHosts = builtins.attrNames (LT.hostsWithTag LT.tags.dn42);
  lgproxyDomain = "ltnet.lantian.pub";
in
{
  networking.hosts = builtins.listToAttrs (builtins.map (
      n:
      let
        ptrPrefix = lib.replaceStrings [ "_" ] [ "-" ] LT.hosts.${n}.city.sanitized;
      in
      {
        name = LT.hosts.${n}.ltnet.IPv4;
        value = [
          (lib.mkBefore "${ptrPrefix}.${n}.${lgproxyDomain}")
          "${n}.${lgproxyDomain}"
        ]
        ++ lib.optionals (config.networking.hostName == n) [
          "local.${lgproxyDomain}"
        ];
      }
    ) lgproxyHosts);

  systemd.services.bird-lg-go = {
    description = "Bird-lg-go";
    wantedBy = [ "multi-user.target" ];
    environment = {
      BIRDLG_DNS_INTERFACE = "asn.lantian.dn42";
      BIRDLG_DOMAIN = lgproxyDomain;
      BIRDLG_LISTEN = "/run/bird-lg-go/bird-lg-go.sock";
      BIRDLG_NAME_FILTER = "^(ltdocker|sys_|static_|ltdyn_)";
      BIRDLG_NET_SPECIFIC_MODE = "dn42_shorten";
      BIRDLG_SERVERS = builtins.concatStringsSep "," (lgproxyHosts ++ [ "local" ]);
      BIRDLG_TELEGRAM_BOT_NAME = "lantian_lg_bot";
      BIRDLG_WHOIS = "172.22.76.108";
    };
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = lib.getExe pkgs.nur-xddxdd.bird-lg-go;
      RuntimeDirectory = "bird-lg-go";
      User = "bird-lg-go";
      Group = "bird-lg-go";
      UMask = "007";
    };
  };
  systemd.services.bird-lgproxy-go.enable = lib.mkForce true;

  lantian.nginxVhosts = {
    "lg.lantian.pub" = {
      locations = {
        "/" = {
          proxyPass = "http://unix:/run/bird-lg-go/bird-lg-go.sock";
          blockBadUserAgents = true;
        };
        # Telegram doesn't recognize gzip/brotli compressed response
        "/telegram/" = {
          proxyPass = "http://unix:/run/bird-lg-go/bird-lg-go.sock";
          blockBadUserAgents = true;
          disableLiveCompression = true;
        };
      };

      sslCertificate = "zerossl-lantian.pub";
      noIndex.enable = true;
    };
    "lg.lantian.dn42" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      serverAliases = [ "lg.lantian.neo" ];
      locations = {
        "/" = {
          proxyPass = "http://unix:/run/bird-lg-go/bird-lg-go.sock";
          blockBadUserAgents = true;
        };
      };

      sslCertificate = "zerossl-lantian.dn42";
      noIndex.enable = true;
    };
  };

  users.users.bird-lg-go = {
    group = "bird-lg-go";
    isSystemUser = true;
  };
  users.groups.bird-lg-go.members = [ "nginx" ];
}
