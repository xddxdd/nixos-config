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
    host:
    if !(LT.this.hasTag "ipv6-only") && host.public.IPv4 != "" then
      host.public.IPv4
    else if LT.this.public.IPv6 != "" && host.public.IPv6 != "" then
      host.public.IPv6
    else
      null;
  targetHosts = lib.filterAttrs (n: v: v.hasTag "server") LT.otherHosts;
in
{
  age.secrets.wg-priv = {
    file = inputs.secrets + "/wg-priv/${config.networking.hostName}.age";
    group = "systemd-network";
    mode = "0660";
  };

  systemd.network.netdevs = lib.mapAttrs' (
    n: v:
    let
      wgEndpoint = wgEndpointFor v;
    in
    lib.nameValuePair "wgmesh${builtins.toString v.index}" {
      netdevConfig = {
        Name = "wgmesh${builtins.toString v.index}";
        Kind = "wireguard";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wg-priv.path;
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
      address = [ "fe80::${builtins.toString LT.this.index}/64" ];
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    }
  ) targetHosts;
}
