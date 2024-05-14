{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
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

  netns = config.lantian.netns.nginx-proxy;
in
{
  # Actual enable is in nixos/common-apps/nginx/proxy.nix
  options.lantian.nginx-proxy.enable = lib.mkEnableOption "nginx-proxy service";

  config = lib.mkIf config.lantian.nginx-proxy.enable {
    lantian.netns.nginx-proxy = {
      ipSuffix = "43";
      announcedIPv4 = [
        "172.22.76.108"
        "198.19.0.243"
        "10.127.10.243"
      ];
      announcedIPv6 = [
        "fdbc:f9dc:67ad:2547::43"
        "fd10:127:10:2547::43"
      ];
      birdBindTo = [ "nginx-proxy.service" ];
    };

    systemd.services.nginx-proxy = netns.bind {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = LT.serviceHarden // {
        ExecStart = "${config.services.nginx.package}/bin/nginx -c ${nginxConfig}";
        Restart = "always";
        RestartSec = "10s";

        AmbientCapabilities = [
          "CAP_NET_BIND_SERVICE"
          "CAP_SYS_RESOURCE"
        ];
        CapabilityBoundingSet = [
          "CAP_NET_BIND_SERVICE"
          "CAP_SYS_RESOURCE"
        ];
        User = config.services.nginx.user;
        Group = config.services.nginx.group;
        MemoryDenyWriteExecute = lib.mkForce false;
        TemporaryFileSystem = [ "/var/log/nginx:mode=0777" ];
        LimitMEMLOCK = "infinity";
      };
    };
  };
}
