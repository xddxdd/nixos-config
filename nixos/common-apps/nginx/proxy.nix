{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  nginxConfig = pkgs.writeText "nginx-proxy.conf" ''
    daemon off;
    error_log syslog:server=unix:/dev/log,nohostname crit;
    events {
      worker_connections 1024;
    }
    stream {
      tcp_nodelay on;
      proxy_socket_keepalive on;
      server {
        listen 43;
        listen [::]:43;
        proxy_pass unix:/run/nginx/whois.sock;
        proxy_protocol on;
      }
      server {
        listen 70;
        listen [::]:70;
        proxy_pass unix:/run/nginx/gopher.sock;
        proxy_protocol on;
      }
    }
  '';

  netns = LT.netns {
    name = "nginx-proxy";
    announcedIPv4 = [
      "172.22.76.108"
      "172.18.0.243"
      "10.127.10.243"
    ];
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::43"
      "fd10:127:10:2547::43"
    ];
    birdBindTo = [ "nginx-proxy.service" ];
  };
in
{
  options.lantian.nginx-proxy.enable = lib.mkOption {
    type = lib.types.bool;
    default = !(builtins.elem LT.tags.low-ram LT.this.tags);
    description = "Enable nginx-proxy service.";
  };

  config = lib.mkIf (config.lantian.nginx-proxy.enable) {
    systemd.services = netns.setup // {
      nginx-proxy = netns.bind {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = LT.serviceHarden // {
          ExecStart = "${config.services.nginx.package}/bin/nginx -c ${nginxConfig}";
          Restart = "always";
          RestartSec = "10s";

          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_SYS_RESOURCE" ];
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_SYS_RESOURCE" ];
          User = config.services.nginx.user;
          Group = config.services.nginx.group;
          MemoryDenyWriteExecute = lib.mkForce false;
          TemporaryFileSystem = [ "/var/log/nginx:mode=0777" ];
        };
      };
    };
  };
}
