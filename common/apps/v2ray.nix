{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  services.v2ray = {
    enable = true;
    config = {
      log = {
        loglevel = "warning";
      };
      "policy" = {
        "levels" = {
          "0" = {
            "connIdle" = 86400;
            "uplinkOnly" = 0;
            "downlinkOnly" = 0;
          };
        };
      };
      "inbounds" = [
        {
          "listen" = "${thisHost.ltnet.IPv4Prefix}.1";
          "port" = 13504;
          "protocol" = "vless";
          "settings" = {
            "clients" = [{
              "id" = "***REMOVED***";
              "flow" = "xtls-rprx-direct";
              "level" = 0;
            }];
            "decryption" = "none";
          };
          "streamSettings" = {
            "network" = "ws";
            "security" = "none";
            "wsSettings" = {
              "path" = "/ray";
            };
          };
          "sniffing" = {
            "enabled" = true;
            "destOverride" = [
              "http"
              "tls"
            ];
          };
        }
      ];
      "outbounds" = [
        {
          "tag" = "direct";
          "protocol" = "freedom";
          "settings" = {
            "domainStrategy" = "UseIPv4";
          };
        }
        {
          "tag" = "blackhole";
          "protocol" = "blackhole";
          "settings" = {
            "response" = {
              "type" = "none";
            };
          };
        }
        {
          "tag" = "dns";
          "protocol" = "freedom";
          "settings" = {
            "redirect" = "172.22.76.109:56";
          };
        }
        {
          "tag" = "music";
          "protocol" = "shadowsocks";
          "settings" = {
            "servers" = [{
              "address" = "music.desperadoj.com";
              "method" = "aes-128-gcm";
              "password" = "desperadoj.com_free_proxy_d39m";
              "port" = 30001;
            }];
          };
        }
      ];
      "routing" = {
        "domainStrategy" = "IPOnDemand";
        "rules" = [
          {
            "type" = "field";
            "port" = 53;
            "outboundTag" = "dns";
          }
          {
            "type" = "field";
            "domain" = [
              "full:api.iplay.163.com"
              "full:apm3.music.163.com"
              "full:apm.music.163.com"
              "full:interface3.music.163.com"
              "full:interface3.music.163.com.163jiasu.com"
              "full:interface.music.163.com"
              "full:music.163.com"
            ];
            "outboundTag" = "music";
          }
          {
            "type" = "field";
            "ip" = [
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
            "outboundTag" = "music";
          }
          {
            "type" = "field";
            "outboundTag" = "block";
            "protocol" = [
              "bittorrent"
            ];
          }
        ];
        "balancers" = [];
      };
      "dns" = {
        "servers" = [
          {
            "address" = "172.22.76.110";
            "port" = 53;
            "domains" = [
              "domain:dn42"
              "domain:hack"
              "domain:rzl"
              "domain:neo"
              "domain:bbs"
              "domain:chan"
              "domain:cyb"
              "domain:dns.opennic.glue"
              "domain:dyn"
              "domain:epic"
              "domain:fur"
              "domain:geek"
              "domain:gopher"
              "domain:indy"
              "domain:libre"
              "domain:null"
              "domain:o"
              "domain:opennic.glue"
              "domain:oss"
              "domain:oz"
              "domain:parody"
              "domain:pirate"
              "domain:bazar"
              "domain:coin"
              "domain:emc"
              "domain:lib"
            ];
          }
          {
            "address" = "172.22.76.109";
            "port" = 56;
          }
        ];
      };
    };
  };
}
