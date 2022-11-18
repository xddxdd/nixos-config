{ config, pkgs, lib, utils, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  v2rayConf = {
    inbounds = [{
      listen = "/run/v2ray/v2ray.sock";
      port = 0;
      protocol = "vless";
      settings = {
        clients = [{
          flow = "xtls-rprx-direct";
          id = { _secret = config.age.secrets.v2ray-key.path; };
          level = 0;
        }];
        decryption = "none";
      };
      sniffing = {
        destOverride = [ "http" "tls" ];
        enabled = true;
      };
      streamSettings = {
        network = "grpc";
        security = "none";
        grpcSettings = {
          serviceName = "ray";
          multiMode = true;
        };
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
        protocol = "freedom";
        settings.redirect = "${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.coredns-client}:55";
        tag = "dns";
      }
      {
        protocol = "shadowsocks";
        settings.servers = [{
          address = "music.desperadoj.com";
          method = "aes-128-gcm";
          password = "desperadoj.com_free_proxy_etg0";
          port = 30001;
        }];
        tag = "music";
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
    file = pkgs.secrets + "/v2ray-key.age";
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
