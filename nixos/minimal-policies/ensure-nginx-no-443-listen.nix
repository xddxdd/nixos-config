{
  config,
  lib,
  ...
}:
let
  # TCP 443 is fronted by the stream{} SNI router; vhosts must only listen on
  # UNIX sockets there. QUIC/UDP 443 listeners are exempt (UDP cannot be
  # SNI-routed), and unix: addresses have no TCP port at all.
  isTcp443Listen =
    listen:
    listen.port == 443
    && !lib.hasPrefix "unix:" listen.addr
    && !builtins.elem "quic" listen.extraParameters
    && !builtins.elem "udp" listen.extraParameters;

  offendingListens = lib.concatLists (
    lib.mapAttrsToList (
      name: v:
      map (listen: "${name}: listen ${listen.addr}:443;") (lib.filter isTcp443Listen (v.listen or [ ]))
    ) config.services.nginx.virtualHosts
  );
in
{
  assertions = [
    {
      assertion = offendingListens == [ ];
      message =
        "nginx vhosts must not listen on TCP 443 directly (fronted by stream SNI router): "
        + lib.concatStringsSep "; " offendingListens;
    }
  ]
  ++ lib.flatten (
    lib.mapAttrsToList (_: v: [
      {
        assertion =
          (v.listenHTTPS.enable && v.listenHTTPS.port == 443)
          -> (v.listenHTTPS_Socket.socket == "/run/nginx/https.sock");
        message = "${v.serverName} listens HTTPS on 443 but its UNIX socket is not the default shared socket";
      }
      {
        assertion =
          (v.listenHTTPS.enable && v.listenHTTPS.port == 443) -> (v.listenHTTPS_Socket.proxyProtocol == true);
        message = "${v.serverName} listens HTTPS on 443 but its UNIX socket listener does not have proxy protocol";
      }
    ]) (config.lantian.nginxVhosts or { })
  );
}
