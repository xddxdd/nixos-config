{ config, pkgs, lib, ... }:

{
  xdg.configFile."pipewire/client.conf.d/override.conf".text = ''
    context.modules = [
      stream.properties = {
        resample.quality = 10
      }
    ]
  '';

  xdg.configFile."pipewire/pipewire-pulse.conf.d/override.conf".text = ''
    context.modules = [
      stream.properties = {
        resample.quality = 10
      }
    ]
  '';
}
