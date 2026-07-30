{
  lib,
  LT,
  ...
}:
{
  services.iperf3 = {
    # Socket-activated, no persistent daemon, so always enable on servers
    enable = true;
    bind = LT.this.ltnet.IPv4;
    port = LT.port.IPerf;
    forceFlush = true;
    # --one-off: handle a single client then exit, letting systemd re-arm the socket
    # Note: do NOT pass --mptcp here. It makes iperf3 close the systemd-provided
    # listener and re-bind a fresh MPTCP socket on the same port, which fails
    # with EADDRINUSE while systemd still holds the port. MPTCP is provided by
    # the socket unit's SocketProtocol = mptcp instead.
    extraFlags = [ "--one-off" ];
  };

  systemd.services.iperf3 = {
    # Activated by the socket, not at boot
    wantedBy = lib.mkForce [ ];
    requires = [ "iperf3.socket" ];
    after = [ "iperf3.socket" ];
  };

  systemd.sockets.iperf3 = {
    listenStreams = [ "${LT.this.ltnet.IPv4}:${LT.portStr.IPerf}" ];
    socketConfig = {
      FreeBind = true;
      SocketProtocol = "mptcp";
    };
    wantedBy = [ "sockets.target" ];
  };
}
