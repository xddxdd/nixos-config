{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  netns = config.lantian.netns.netease;

  netease-cloud-music = pkgs.nur.repos.Freed-Wu.netease-cloud-music;

  # https://desperadoj.com/16.html
  xrayConfig = pkgs.writeText "config.json" (builtins.toJSON {
    inbounds = [
      {
        listen = LT.this.ltnet.IPv4;
        port = LT.port.NeteaseUnlock;
        protocol = "dokodemo-door";
        settings = {
          network = "tcp,udp";
          followRedirect = true;
        };
        sniffing = {
          destOverride = [
            "http"
            "tls"
          ];
          enabled = true;
        };
      }
    ];

    log.loglevel = "warning";

    outbounds = [
      {
        protocol = "freedom";
        settings = {
          domainStrategy = "UseIPv4";
        };
        tag = "direct";
      }
      {
        protocol = "blackhole";
        settings = {
          response = {
            type = "none";
          };
        };
        tag = "blackhole";
      }
      {
        protocol = "shadowsocks";
        settings = {
          servers = [
            {
              address = "music.desperadoj.com";
              method = "aes-128-gcm";
              password = "desperadoj.com_free_proxy_etg0";
              port = 30001;
            }
          ];
        };
        tag = "music";
      }
    ];

    routing = {
      balancers = [];
      domainStrategy = "IPOnDemand";
      rules = [
        {
          domain = [
            "full:api.iplay.163.com"
            "full:apm3.music.163.com"
            "full:apm.music.163.com"
            "full:interface3.music.163.com"
            "full:interface3.music.163.com.163jiasu.com"
            "full:interface.music.163.com"
            "full:music.163.com"
          ];
          outboundTag = "music";
          type = "field";
        }
        {
          ip = [
            "39.105.63.80/32"
            "39.105.175.128/32"
            "45.254.48.1/32"
            "47.100.127.239/32"
            "59.111.160.195/32"
            "59.111.160.197/32"
            "59.111.181.35/32"
            "59.111.181.38/32"
            "59.111.181.60/32"
            "101.71.154.241/32"
            "103.126.92.132/32"
            "103.126.92.133/32"
            "112.13.119.17/32"
            "112.13.119.18/32"
            "112.13.122.1/32"
            "112.13.122.4/32"
            "115.236.118.33/32"
            "115.236.121.1/32"
            "118.24.63.156/32"
            "182.92.170.253/32"
            "193.112.159.225/32"
            "223.252.199.66/32"
            "223.252.199.67/32"
          ];
          outboundTag = "music";
          type = "field";
        }
        {
          domain = [
            "full:admusicpic.music.126.net"
            "full:iadmat.nosdn.127.net"
            "full:iadmusicmat.music.126.net"
            "full:iadmusicmatvideo.music.126.net"
          ];
          outboundTag = "blackhole";
          type = "field";
        }
      ];
    };
  });
in {
  environment.systemPackages = [netease-cloud-music];

  environment.etc."netns/netease/resolv.conf".text = ''
    nameserver 114.114.114.114
    options edns0
  '';

  lantian.netns.netease = {
    ipSuffix = "2";
  };

  systemd.services = {
    netns-netease-xray = {
      after = ["netns-instance-netease.service"];
      bindsTo = ["netns-instance-netease.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStartPre = [
          # Redirect all connection to xray
          "${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ns-netease -p tcp -j REDIRECT --to-ports ${LT.portStr.NeteaseUnlock}"
          # Block IPv6 to prevent leaks
          "${pkgs.iptables}/bin/ip6tables -A INPUT -i ns-netease -j REJECT"
        ];
        ExecStart = "${pkgs.xray}/bin/xray -c ${xrayConfig}";
        ExecStopPost = [
          "${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ns-netease -p tcp -j REDIRECT --to-ports ${LT.portStr.NeteaseUnlock}"
          "${pkgs.iptables}/bin/ip6tables -D INPUT -i ns-netease -j REJECT"
        ];
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };

  security.wrappers.netease-cloud-music = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
    source = pkgs.writeShellScript "netease-cloud-music" ''
      ${pkgs.netns-exec}/bin/netns-exec-dbus -- netease \
        env \
          QT_AUTO_SCREEN_SCALE_FACTOR=$QT_AUTO_SCREEN_SCALE_FACTOR \
          QT_SCREEN_SCALE_FACTORS=$QT_SCREEN_SCALE_FACTORS \
          XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
        ${netease-cloud-music}/bin/netease-cloud-music \
        --ignore-certificate-errors
    '';
  };
}
