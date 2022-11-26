{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;

  v2rayConf = {
    inbounds = [{
      listen = "127.0.0.1";
      port = LT.port.V2Ray.SocksClient;
      protocol = "socks";
      settings.udp = true;
      sniffing = {
        destOverride = [ "http" "tls" ];
        enabled = true;
      };
    }];
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
        tag = "blackhole";
      }
      {
        protocol = "trojan";
        settings.servers = [
          {
            address = LT.hosts."hostdare".public.IPv4;
            port = 443;
            password = { _secret = config.age.secrets.v2ray-key.path; };
          }
        ];
        streamSettings = {
          network = "grpc";
          security = "tls";
          tlsSettings = {
            serverName = "lantian.pub";
            fingerprint = "firefox";
          };
          grpcSettings = {
            serviceName = "ray";
            multiMode = false;
            idle_timeout = 25;
            health_check_timeout = 10;
          };
        };
        tag = "proxy";
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
          outboundTag = "block";
          protocol = [ "bittorrent" ];
          type = "field";
        }
        {
          domain = [ "geosite:cn" ];
          outboundTag = "proxy";
          type = "field";
        }
        {
          ip = [ "geoip:cn" ];
          outboundTag = "proxy";
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
    script = ''
      rm -f /run/v2ray/v2ray.sock

      ${utils.genJqSecretsReplacementSnippet
        v2rayConf
        "/run/v2ray/config.json"}

      exec ${pkgs.xray}/bin/v2ray -config /run/v2ray/config.json
    '';
    serviceConfig = LT.serviceHarden // {
      User = "nginx";
      Group = "nginx";
      RuntimeDirectory = "v2ray";
    };
  };
}