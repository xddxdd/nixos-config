{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
  hostPkgs = pkgs;
  hostConfig = config;
  containerIP = 43;
in
{
  containers.nginx-proxy = {
    autoStart = true;
    ephemeral = true;
    additionalCapabilities = [ "CAP_NET_ADMIN" ];

    privateNetwork = true;
    hostAddress = "${thisHost.ltnet.IPv4Prefix}.1";
    hostAddress6 = "${thisHost.ltnet.IPv6Prefix}::1";
    localAddress = "${thisHost.ltnet.IPv4Prefix}.${builtins.toString containerIP}";
    localAddress6 = "${thisHost.ltnet.IPv6Prefix}::${builtins.toString containerIP}";

    config = { config, pkgs, ... }: {
      system.stateVersion = "21.05";
      nixpkgs.pkgs = hostPkgs;
      networking.hostName = hostConfig.networking.hostName;
      networking.firewall.enable = false;
      services.journald.extraConfig = ''
        SystemMaxUse=50M
        SystemMaxFileSize=10M
      '';

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

      services.bird2 = {
        enable = true;
        checkConfig = false;
        config = ''
          log stderr { error, fatal };
          router id ${thisHost.ltnet.IPv4Prefix}.${builtins.toString containerIP};
          protocol device {}

          protocol babel {
            ipv4 {
              import none;
              export all;
            };
            ipv6 {
              import none;
              export all;
            };
            interface "eth*" {
              type wired;
              hello interval 1s;
              update interval 1s;
              port 6695;
            };
          }

          protocol static {
            ipv4;
            route 172.22.76.108/32 unreachable;
            route 172.18.0.243/32 unreachable;
            route 10.127.10.243/32 unreachable;
          }

          protocol static {
            ipv6;
            route fdbc:f9dc:67ad:2547::43/128 unreachable;
            route fd10:127:10:2547::43/128 unreachable;
          }
        '';
      };

      services.resolved.enable = false;

      systemd.network.enable = true;
      systemd.network.netdevs.dummy0 = {
        netdevConfig = {
          Kind = "dummy";
          Name = "dummy0";
        };
      };

      systemd.network.networks.dummy0 = {
        matchConfig = {
          Name = "dummy0";
        };

        networkConfig = {
          IPv6PrivacyExtensions = false;
        };

        addresses = [
          { addressConfig = { Address = "172.22.76.108/32"; }; }
          { addressConfig = { Address = "172.18.0.243/32"; }; }
          { addressConfig = { Address = "10.127.10.243/32"; }; }
          { addressConfig = { Address = "fdbc:f9dc:67ad:2547::43/128"; }; }
          { addressConfig = { Address = "fd10:127:10:2547::43/128"; }; }
        ];
      };
    };
  };
}
