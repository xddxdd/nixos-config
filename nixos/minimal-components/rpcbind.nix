{
  LT,
  ...
}:
{
  # rpcbind (111) is enabled by the NixOS default; it is LAN-internal only.
  lantian.firewall.presets.public-firewall.allowedInternalPorts = [ LT.port.Rpcbind ];
}
