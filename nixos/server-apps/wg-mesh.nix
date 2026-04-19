{
  LT,
  lib,
  config,
  inputs,
  ...
}:
let
  wg-pubkey = import (inputs.secrets + "/wg-pubkey.nix");
  wgEndpointFor =
    name: host:
    if !(LT.this.hasTag "ipv6-only") && LT.publicIPv4For name != null then
      LT.publicIPv4For name
    else if LT.this.public.IPv6 != null && LT.publicIPv6For name != null then
      LT.publicIPv6For name
    else
      null;
  targetHosts = lib.filterAttrs (n: v: v.hasTag "server") LT.otherHosts;
in
{
  sops.secrets.wg-priv = {
    sopsFile = inputs.secrets + "/per-host/wg-priv/${config.networking.hostName}.yaml";
    group = "systemd-network";
    mode = "0660";
  };

  systemd.network.netdevs = lib.mapAttrs' (
    n: v:
    let
      wgEndpoint = wgEndpointFor n v;
    in
    lib.nameValuePair "wgmesh${builtins.toString v.index}" {
      netdevConfig = {
        Name = "wgmesh${builtins.toString v.index}";
        Kind = "wireguard";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wg-priv.path;
        ListenPort = LT.port.WGMesh.Start + v.index;
      };
      wireguardPeers = [
        (
          {
            AllowedIPs = [
              "0.0.0.0/0"
              "::/0"
            ];
            PublicKey = wg-pubkey."${n}";
            PersistentKeepalive = 15;
          }
          // lib.optionalAttrs (wgEndpoint != null) {
            Endpoint = "${wgEndpoint}:${builtins.toString (LT.port.WGMesh.Start + LT.this.index)}";
          }
        )
      ];
    }
  ) targetHosts;

  systemd.network.networks = lib.mapAttrs' (
    n: v:
    lib.nameValuePair "wgmesh${builtins.toString v.index}" {
      matchConfig = {
        Name = "wgmesh${builtins.toString v.index}";
        Kind = "wireguard";
      };

      address = [
        "fe80::${builtins.toString LT.this.index}/64"
      ]
      ++ lib.optionals (LT.this.ltnet.IPv4 != null) [ (LT.this.ltnet.IPv4 + "/32") ]
      ++ lib.optionals (LT.this.ltnet.IPv6 != null) [ (LT.this.ltnet.IPv6 + "/128") ];

      linkConfig.MTUBytes = 1400;
      networkConfig = {
        LinkLocalAddressing = "no";
      };
      routes = [
        {
          Destination = "0.0.0.0/0";
          Table = 10000 + v.index;
        }
        {
          Destination = "::/0";
          Table = 10000 + v.index;
        }
      ];
    }
  ) targetHosts;

  services.prometheus.exporters.wireguard = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.WireGuardExporter;
    latestHandshakeDelay = true;
  };
}
