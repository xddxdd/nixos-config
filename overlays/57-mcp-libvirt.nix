{ inputs, ... }:
final: prev: {
  mcp-libvirt = inputs.mcp-libvirt-vm-use.packages.${prev.stdenv.hostPlatform.system}.default;
}
