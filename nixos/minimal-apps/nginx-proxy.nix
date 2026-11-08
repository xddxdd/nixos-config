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
      server {
        listen 1965;
        listen [::]:1965;
        proxy_pass unix:/run/nginx/gemini.sock;
        proxy_protocol on;
      }
    }
  '';

  netns = config.lantian.netns.nginx-proxy;

  proxyPorts =
    lib.genAttrs
      (map (p: LT.portStr.${p}) [
        "Whois"
        "Gopher"
        "Gemini"
      ])
      (_: {
        type = "forward";
        inherit (netns) ipv4 ipv6;
      });
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

    lantian.firewall.zones = {
      DN42 = {
        forwardTo = [ "NETNS_NGINX_PROXY" ];
        tcpPorts = proxyPorts;
      };
      LAN = {
        forwardTo = [ "NETNS_NGINX_PROXY" ];
        tcpPorts = proxyPorts;
      };
      LTNET = {
        forwardTo = [ "NETNS_NGINX_PROXY" ];
        tcpPorts = proxyPorts;
      };
      WAN.tcpPorts = proxyPorts;
    };

    systemd.services.nginx-proxy = netns.bind {
      wantedBy = [ "multi-user.target" ];
      after = [ "nginx.service" ];
      requires = [ "nginx.service" ];
      serviceConfig = {
        ExecStart = "${lib.getExe config.services.nginx.package} -c ${nginxConfig}";
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
        PrivateUsers = false; # For binding to privileged ports

        User = config.services.nginx.user;
        Group = config.services.nginx.group;
        MemoryDenyWriteExecute = lib.mkForce false;
        TemporaryFileSystem = [ "/var/log/nginx:mode=0777" ];
        BindReadOnlyPaths = [ "/run/nginx" ];
        LimitMEMLOCK = "infinity";
        SystemCallFilter = [ ];
      };
    };
    lantian.harden.nginx-proxy.enable = true;
  };
}
