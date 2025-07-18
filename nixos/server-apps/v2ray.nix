{
  pkgs,
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
        listen = "/run/v2ray/v2ray.sock";
        port = 0;
        protocol = "vless";
        settings = {
          clients = [
            {
              id = {
                _secret = config.age.secrets.v2ray-key.path;
              };
            }
          ];
          decryption = "none";
        };
        sniffing = {
          destOverride = [
            "http"
            "tls"
            "quic"
          ];
          enabled = true;
        };
        streamSettings = {
          network = "xhttp";
          xhttpSettings = {
            mode = "stream-up";
            path = "/ray";
          };
        };
      }
    ];
    log = {
      access = "none";
      loglevel = "warning";
    };
    outbounds = [
      {
        protocol = "freedom";
        settings.domainStrategy = "UseIPv4";
        tag = "direct";
      }
      {
        protocol = "blackhole";
        settings.response.type = "none";
        tag = "block";
      }
      {
        protocol = "freedom";
        settings.redirect = "${
          config.lantian.netns.coredns-client.ipv4 or config.lantian.netns.powerdns-recursor.ipv4
        }:${LT.portStr.DNS}";
        tag = "dns";
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
          outboundTag = "dns";
          port = 53;
          type = "field";
        }
        {
          outboundTag = "block";
          protocol = [ "bittorrent" ];
          type = "field";
        }
      ];
    };
  };
in
{
  age.secrets.v2ray-key = {
    file = inputs.secrets + "/v2ray-key.age";
    owner = "nginx";
    group = "nginx";
  };

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

      exec ${pkgs.xray}/bin/xray -config /run/v2ray/config.json
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
