{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.imsprog ];

  # https://github.com/setarcos/ch341prog/blob/master/99-ch341a-prog.rules
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="5512", MODE="0666"
  '';
}
