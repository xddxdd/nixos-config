_: {
  imports = [ ../hardware/vfio.nix ];

  virtualisation.virtualbox.host = {
    enable = true;
    addNetworkInterface = false;
    enableExtensionPack = true;
    enableHardening = false;
    enableKvm = true;
  };
}
