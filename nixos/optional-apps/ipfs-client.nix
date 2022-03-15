{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };

  netns = LT.netns {
    name = "wg-lantian";
    setupDefaultRoute = false;
  };
in
{
  services.ipfs = {
    enable = true;
    apiAddress = "/ip4/${netns.ipv4}/tcp/${LT.portStr.IPFS.API}";
    gatewayAddress = "/ip4/${netns.ipv4}/tcp/${LT.portStr.IPFS.Gateway}";
    serviceFdlimit = 65536;
    extraConfig = {
      API.HTTPHeaders = {
        Access-Control-Allow-Origin = [
          "http://webui.ipfs.io.ipns.localhost:8080"
          "http://localhost:3000"
          "http://127.0.0.1:5001"
          "https://webui.ipfs.io"
        ];
        Access-Control-Allow-Methods = [ "PUT" "POST" ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "A+ /var/lib/ipfs - - - - g:wheel:rwx,d:g:wheel:rwx"
  ];

  systemd.services.ipfs = pkgs.lib.recursiveUpdate netns.bindExisting {
    serviceConfig = LT.serviceHarden // {
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      BindReadOnlyPaths = [ "/etc/netns/ns-wg-lantian/resolv.conf:/etc/resolv.conf" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
    };
  };

  systemd.sockets.ipfs-api.enable = false;
  systemd.sockets.ipfs-gateway.enable = false;

  systemd.sockets.ipfs-proxy-api = {
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = [
        "127.0.0.1:${LT.portStr.IPFS.API}"
        "[::1]:${LT.portStr.IPFS.API}"
      ];
      Service = "ipfs-proxy-api.service";
    };
  };

  systemd.services.ipfs-proxy-api = {
    after = [ "network.target" ];
    requires = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${netns.ipv4}:${LT.portStr.IPFS.API}";
    };
  };

  systemd.sockets.ipfs-proxy-gateway = {
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = [
        "127.0.0.1:${LT.portStr.IPFS.Gateway}"
        "[::1]:${LT.portStr.IPFS.Gateway}"
      ];
      Service = "ipfs-proxy-gateway.service";
    };
  };

  systemd.services.ipfs-proxy-gateway = {
    after = [ "network.target" ];
    requires = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${netns.ipv4}:${LT.portStr.IPFS.Gateway}";
    };
  };
}
