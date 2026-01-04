{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}:
let
  v2rayConf = {
    inbounds = [
      {
        listen = "127.0.0.1";
        port = LT.port.V2Ray.SocksClient;
        protocol = "socks";
        settings.udp = true;
        sniffing = {
          destOverride = [
            "http"
            "tls"
            "quic"
          ];
          enabled = true;
        };
        tag = "inbound";
      }
      {
        listen = "127.0.0.1";
        port = LT.port.V2Ray.UnblockCNClient;
        protocol = "socks";
        settings.udp = true;
        sniffing = {
          destOverride = [
            "http"
            "tls"
            "quic"
          ];
          enabled = true;
        };
        tag = "inbound-unblock-cn";
      }
    ];
    log = {
      access = "none";
      loglevel = "warning";
    };
    outbounds = [
      {
        protocol = "vless";
        settings.vnext = [
          {
            address = LT.hosts."bwg-lax".public.IPv4;
            port = 443;
            users = [
              {
                id = {
                  _secret = config.age.secrets.v2ray-key.path;
                };
                encryption = "none";
              }
            ];
          }
        ];
        streamSettings =
          let
            network = "xhttp";
            security = "tls";
            tlsSettings = {
              serverName = "lantian.pub";
              fingerprint = "firefox";
            };
            xhttpSettings = {
              host = "lantian.pub";
              path = "/ray";
              xmux = {
                maxConcurrency = 128;
                hMaxRequestTimes = 86400;
                hMaxReusableSecs = 86400;
              };
            };
          in
          {
            inherit network security tlsSettings;
            xhttpSettings = xhttpSettings // {
              mode = "stream-up";
              downloadSettings = {
                address = LT.hosts."bwg-lax".public.IPv4;
                port = 443;
                inherit
                  network
                  security
                  tlsSettings
                  xhttpSettings
                  ;
              };
            };
          };
        tag = "proxy";
      }
      {
        protocol = "freedom";
        settings.domainStrategy = "UseIPv4";
        tag = "direct";
      }
      {
        protocol = "blackhole";
        settings.response.type = "none";
        tag = "blackhole";
      }
      {
        protocol = "shadowsocks";
        settings.servers = [
          {
            address = {
              _secret = config.age.secrets.v2ray-unblock-cn-host.path;
            };
            port = 10076;
            method = "chacha20-ietf-poly1305";
            ota = true;
            password = {
              _secret = config.age.secrets.v2ray-unblock-cn-pass.path;
            };
          }
        ];
        tag = "unblock-cn";
      }
    ];
    policy.levels."0" = {
      connIdle = 86400;
      downlinkOnly = 0;
      uplinkOnly = 0;
    };
    routing = {
      balancers = [ ];
      domainStrategy = "IPOnDemand";
      rules = [
        {
          inboundTag = [ "inbound-unblock-cn" ];
          outboundTag = "unblock-cn";
          type = "field";
        }
        {
          outboundTag = "block";
          protocol = [ "bittorrent" ];
          type = "field";
        }
        {
          domain = [
            "geosite:private"
            "geosite:cn"
            "category-games@cn"
          ];
          outboundTag = "direct";
          type = "field";
        }
        {
          ip = [
            "geoip:private"
            "geoip:cn"
          ];
          outboundTag = "direct";
          type = "field";
        }
      ];
    };
  };
in
{
  age.secrets = lib.genAttrs [ "v2ray-key" "v2ray-unblock-cn-host" "v2ray-unblock-cn-pass" ] (n: {
    file = inputs.secrets + "/${n}.age";
    owner = "nginx";
    group = "nginx";
  });

  systemd.services.v2ray = {
    description = "v2ray Daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment =
      let
        assets = pkgs.symlinkJoin {
          name = "v2ray-assets";
          paths = with pkgs; [
            v2ray-geoip
            v2ray-domain-list-community
          ];
        };
      in
      {
        V2RAY_LOCATION_ASSET = "${assets}/share/v2ray";
        XRAY_LOCATION_ASSET = "${assets}/share/v2ray";
      };
    script = ''
      rm -f /run/v2ray/v2ray.sock

      ${utils.genJqSecretsReplacementSnippet v2rayConf "/run/v2ray/config.json"}

      exec ${lib.getExe pkgs.xray} -config /run/v2ray/config.json
    '';
    serviceConfig = LT.serviceHarden // {
      User = "nginx";
      Group = "nginx";
      RuntimeDirectory = "v2ray";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
