{
  config,
  lib,
  LT,
  pkgs,
  ...
}:
let
  port = builtins.toString (LT.this.wg-lantian.forwardStart + LT.portForwardOffset.IPFS);
in
{
  imports = [ ./netns-tnl-buyvm.nix ];

  environment.systemPackages = [
    (lib.hiPrio (
      pkgs.runCommand "ipfs-cli" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir -p $out/bin
        makeWrapper ${lib.getExe config.services.kubo.package} $out/bin/ipfs \
          --add-flags "--api=/unix/run/ipfs.sock"
      ''
    ))
  ];

  services.kubo = {
    enable = true;
    localDiscovery = LT.this.interconnect.name != null;
    settings.Addresses = {
      API = [
        "/ip4/127.0.0.1/tcp/${LT.portStr.IPFS.API}"
        "/ip6/::1/tcp/${LT.portStr.IPFS.API}"
      ];
      Gateway = [
        "/unix/run/ipfs-gateway.sock"
        # For browser access
        "/ip4/127.0.0.1/tcp/${LT.portStr.IPFS.Gateway}"
        "/ip6/::1/tcp/${LT.portStr.IPFS.Gateway}"
      ];
      Swarm = [
        "/ip4/0.0.0.0/tcp/${port}"
        "/ip6/::/tcp/${port}"
        "/ip4/0.0.0.0/udp/${port}/quic-v1"
        "/ip4/0.0.0.0/udp/${port}/quic-v1/webtransport"
        "/ip4/0.0.0.0/udp/${port}/webrtc-direct"
        "/ip6/::/udp/${port}/quic-v1"
        "/ip6/::/udp/${port}/quic-v1/webtransport"
        "/ip6/::/udp/${port}/webrtc-direct"
      ];
    };
  };

  systemd.services.ipfs = config.lantian.netns.tnl-buyvm.bind {
    serviceConfig.Restart = "on-failure";
  };

  users.users.lantian.extraGroups = [ config.services.kubo.group ];
  users.users.nginx.extraGroups = [ config.services.kubo.group ];

  lantian.localVhosts = {
    ipfs = {
      locations = {
        "/" = {
          proxyPass = "http://unix:/run/ipfs-gateway.sock";
          enableOAuth = true;
        };
      };
    };
    ipfs-api = {
      locations = {
        "/" = {
          proxyPass = "http://unix:/run/ipfs.sock";
          enableOAuth = true;
        };
      };
    };
  };
}
