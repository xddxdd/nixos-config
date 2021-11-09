{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
  containerIP = 43;

  container = import ../helpers/container.nix { inherit config pkgs; };
in
{
  containers.nginx-proxy = container {
    inherit containerIP;

    announcedIPv4 = [
      "172.22.76.108"
      "172.18.0.243"
      "10.127.10.243"
    ];
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::43"
      "fd10:127:10:2547::43"
    ];

    innerConfig = {
      services.nginx.enable = true;
      services.nginx.config = ''
        events {
          worker_connections 1024;
        }
        stream {
          tcp_nodelay on;
          proxy_socket_keepalive on;
          server {
            listen 43;
            listen [::]:43;
            proxy_pass ${thisHost.ltnet.IPv4Prefix}.1:13243;
            proxy_protocol on;
          }
          server {
            listen 70;
            listen [::]:70;
            proxy_pass ${thisHost.ltnet.IPv4Prefix}.1:13270;
            proxy_protocol on;
          }
        }
      '';
    };
  };
}
