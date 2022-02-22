{ pkgs, config, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      ovmf.enable = true;
      swtpm.enable = true;
    };
  };

  users.users.lantian.extraGroups = [ "libvirtd" ];
}
