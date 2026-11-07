{
  LT,
  ...
}:
{
  # rpcbind (111) is enabled by the NixOS default; it is LAN-internal only.
  lantian.firewall.zones.LAN.tcpPorts."${LT.portStr.Rpcbind}" = {
    type = "local";
  };
  lantian.firewall.zones.LAN.udpPorts."${LT.portStr.Rpcbind}" = {
    type = "local";
  };
}
