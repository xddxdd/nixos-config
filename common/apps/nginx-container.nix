{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
  hostPkgs = pkgs;
  hostConfig = config;
  containerIP = 80;
in
{
  containers.nginx = {
    autoStart = true;
    ephemeral = true;

    # bindMounts = {
    #   "/srv" = { hostPath = "/srv"; isReadOnly = false; };
    #   "/var/log/nginx" = { hostPath = "/srv/log/nginx"; isReadOnly = false; };
    # };

    # forwardPorts = [
    #   { hostPort = 80; containerPort = 80; protocol = "tcp"; }
    #   { hostPort = 443; containerPort = 443; protocol = "tcp"; }
    #   { hostPort = 443; containerPort = 443; protocol = "udp"; }
    #   { hostPort = 43; containerPort = 43; protocol = "tcp"; }
    #   { hostPort = 70; containerPort = 70; protocol = "tcp"; }
    # ];

    privateNetwork = true;
    hostBridge = "ltnet";
    localAddress = "${thisHost.ltnet.IPv4Prefix}.${builtins.toString containerIP}/24";
    localAddress6 = "${thisHost.ltnet.IPv6Prefix}::${builtins.toString containerIP}/64";

    config = { config, pkgs, ... }: {
      # imports = [ ./nginx-config.nix ];
      system.stateVersion = "21.05";
      nixpkgs.pkgs = hostPkgs;
      networking.hostName = hostConfig.networking.hostName;
      networking.defaultGateway = "${thisHost.ltnet.IPv4Prefix}.1";
      networking.defaultGateway6 = "${thisHost.ltnet.IPv6Prefix}::1";
      networking.firewall.enable = false;
      services.journald.extraConfig = ''
        SystemMaxUse=50M
        SystemMaxFileSize=10M
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/log/nginx 750 60 60"
  ];
}
