{
  LT,
  ...
}:
let
  rpcbindPorts = {
    "${LT.portStr.Rpcbind}".type = "local";
  };
in
{
  # rpcbind (111) is enabled by the NixOS default; it is LAN/LTnet-internal.
  lantian.firewall.zones = {
    LAN.ports = rpcbindPorts;
    LTNET.ports = rpcbindPorts;
  };
}
