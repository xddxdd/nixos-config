{
  LT,
  ...
}:
{
  # rpcbind (111) is enabled by the NixOS default; it is LAN-internal only.
  lantian.port-audit.additionalPorts = [ LT.port.Rpcbind ];
}
