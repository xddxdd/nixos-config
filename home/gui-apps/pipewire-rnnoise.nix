{ config, pkgs, lib, ... }:

{
  # https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Filter-Chain#virtual-surround
  xdg.configFile."pipewire/pipewire.conf.d/rnnoise.conf".text = ''
    context.modules = [
      { name = libpipewire-module-filter-chain
        args = {
          node.name =  "rnnoise_source"
          node.description =  "Noise Canceling source"
          media.name =  "Noise Canceling source"
          filter.graph = {
            nodes = [
              {
                type = ladspa
                name = rnnoise
                plugin = ${pkgs.noise-suppression-for-voice}/lib/ladspa/librnnoise_ladspa.so
                label = noise_suppressor_stereo
                control = {
                  "VAD Threshold (%)" 50.0
                }
              }
            ]
          }
          capture.props = {
            node.passive = true
          }
          playback.props = {
            media.class = Audio/Source
          }
        }
      }
    ]
  '';
}
