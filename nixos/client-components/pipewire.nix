{ config, pkgs, lib, ... }:

let
  defaultCfg = {
    client = lib.importJSON (pkgs.flake.nixpkgs + "/nixos/modules/services/desktops/pipewire/daemon/client.conf.json");
    client-rt = lib.importJSON (pkgs.flake.nixpkgs + "/nixos/modules/services/desktops/pipewire/daemon/client-rt.conf.json");
    jack = lib.importJSON (pkgs.flake.nixpkgs + "/nixos/modules/services/desktops/pipewire/daemon/jack.conf.json");
    pipewire = lib.importJSON (pkgs.flake.nixpkgs + "/nixos/modules/services/desktops/pipewire/daemon/pipewire.conf.json");
    pipewire-pulse = lib.importJSON (pkgs.flake.nixpkgs + "/nixos/modules/services/desktops/pipewire/daemon/pipewire-pulse.conf.json");
  };

  hesuvi-hrir = "${pkgs.hesuvi-hrir}/atmos.wav";
in
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;

    media-session.enable = false;
    wireplumber.enable = true;

    config = {
      client = {
        "stream.properties"."resample.quality" = 10;
      };
      client-rt = {
        "stream.properties"."resample.quality" = 10;
      };
      jack = {
        "stream.properties"."resample.quality" = 10;
      };
      pipewire-pulse = {
        "stream.properties"."resample.quality" = 10;
      };

      pipewire = {
        "context.modules" = defaultCfg.pipewire."context.modules" ++ [
          {
            name = "libpipewire-module-filter-chain";
            args = {
              "node.name" = "rnnoise_source";
              "node.description" = "Noise Canceling source";
              "media.name" = "Noise Canceling source";
              "filter.graph" = {
                nodes = [
                  {
                    type = "ladspa";
                    name = "rnnoise";
                    plugin = "${pkgs.noise-suppression-for-voice}/lib/ladspa/librnnoise_ladspa.so";
                    label = "noise_suppressor_stereo";
                    control = {
                      "VAD Threshold (%)" = 50.0;
                    };
                  }
                ];
              };
              "capture.props" = {
                "node.passive" = true;
              };
              "playback.props" = {
                "media.class" = "Audio/Source";
              };
            };
          }
        ];
      };
    };
  };

  # For some reason PipeWire fails to start when this is converted to JSON
  environment.etc."pipewire/pipewire.conf.d/surround.conf".text = ''
    context.modules = [
      { name = libpipewire-module-filter-chain
        args = {
          node.name        = "effect_output.virtual-surround-7.1-hesuvi"
          node.description = "Virtual Surround Sink"
          media.name       = "Virtual Surround Sink"
          filter.graph = {
            nodes = [
              # duplicate inputs
              { type = builtin label = copy name = copyFL  }
              { type = builtin label = copy name = copyFR  }
              { type = builtin label = copy name = copyFC  }
              { type = builtin label = copy name = copyRL  }
              { type = builtin label = copy name = copyRR  }
              { type = builtin label = copy name = copySL  }
              { type = builtin label = copy name = copySR  }
              { type = builtin label = copy name = copyLFE }

              # apply hrir - HeSuVi 14-channel WAV (not the *-.wav variants) (note: */44/* in HeSuVi are the same, but resampled to 44100)
              { type = builtin label = convolver name = convFL_L config = { filename = "${hesuvi-hrir}" channel =  0 } }
              { type = builtin label = convolver name = convFL_R config = { filename = "${hesuvi-hrir}" channel =  1 } }
              { type = builtin label = convolver name = convSL_L config = { filename = "${hesuvi-hrir}" channel =  2 } }
              { type = builtin label = convolver name = convSL_R config = { filename = "${hesuvi-hrir}" channel =  3 } }
              { type = builtin label = convolver name = convRL_L config = { filename = "${hesuvi-hrir}" channel =  4 } }
              { type = builtin label = convolver name = convRL_R config = { filename = "${hesuvi-hrir}" channel =  5 } }
              { type = builtin label = convolver name = convFC_L config = { filename = "${hesuvi-hrir}" channel =  6 } }
              { type = builtin label = convolver name = convFR_R config = { filename = "${hesuvi-hrir}" channel =  7 } }
              { type = builtin label = convolver name = convFR_L config = { filename = "${hesuvi-hrir}" channel =  8 } }
              { type = builtin label = convolver name = convSR_R config = { filename = "${hesuvi-hrir}" channel =  9 } }
              { type = builtin label = convolver name = convSR_L config = { filename = "${hesuvi-hrir}" channel = 10 } }
              { type = builtin label = convolver name = convRR_R config = { filename = "${hesuvi-hrir}" channel = 11 } }
              { type = builtin label = convolver name = convRR_L config = { filename = "${hesuvi-hrir}" channel = 12 } }
              { type = builtin label = convolver name = convFC_R config = { filename = "${hesuvi-hrir}" channel = 13 } }

              # treat LFE as FC
              { type = builtin label = convolver name = convLFE_L config = { filename = "${hesuvi-hrir}" channel =  6 } }
              { type = builtin label = convolver name = convLFE_R config = { filename = "${hesuvi-hrir}" channel = 13 } }

              # stereo output
              { type = builtin label = mixer name = mixL }
              { type = builtin label = mixer name = mixR }
            ]
            links = [
              # input
              { output = "copyFL:Out"  input="convFL_L:In"  }
              { output = "copyFL:Out"  input="convFL_R:In"  }
              { output = "copySL:Out"  input="convSL_L:In"  }
              { output = "copySL:Out"  input="convSL_R:In"  }
              { output = "copyRL:Out"  input="convRL_L:In"  }
              { output = "copyRL:Out"  input="convRL_R:In"  }
              { output = "copyFC:Out"  input="convFC_L:In"  }
              { output = "copyFR:Out"  input="convFR_R:In"  }
              { output = "copyFR:Out"  input="convFR_L:In"  }
              { output = "copySR:Out"  input="convSR_R:In"  }
              { output = "copySR:Out"  input="convSR_L:In"  }
              { output = "copyRR:Out"  input="convRR_R:In"  }
              { output = "copyRR:Out"  input="convRR_L:In"  }
              { output = "copyFC:Out"  input="convFC_R:In"  }
              { output = "copyLFE:Out" input="convLFE_L:In" }
              { output = "copyLFE:Out" input="convLFE_R:In" }

              # output
              { output = "convFL_L:Out"  input="mixL:In 1" }
              { output = "convFL_R:Out"  input="mixR:In 1" }
              { output = "convSL_L:Out"  input="mixL:In 2" }
              { output = "convSL_R:Out"  input="mixR:In 2" }
              { output = "convRL_L:Out"  input="mixL:In 3" }
              { output = "convRL_R:Out"  input="mixR:In 3" }
              { output = "convFC_L:Out"  input="mixL:In 4" }
              { output = "convFC_R:Out"  input="mixR:In 4" }
              { output = "convFR_R:Out"  input="mixR:In 5" }
              { output = "convFR_L:Out"  input="mixL:In 5" }
              { output = "convSR_R:Out"  input="mixR:In 6" }
              { output = "convSR_L:Out"  input="mixL:In 6" }
              { output = "convRR_R:Out"  input="mixR:In 7" }
              { output = "convRR_L:Out"  input="mixL:In 7" }
              { output = "convLFE_R:Out" input="mixR:In 8" }
              { output = "convLFE_L:Out" input="mixL:In 8" }
            ]
            inputs  = [ "copyFL:In" "copyFR:In" "copyFC:In" "copyLFE:In" "copyRL:In" "copyRR:In", "copySL:In", "copySR:In" ]
            outputs = [ "mixL:Out" "mixR:Out" ]
          }
          capture.props = {
            media.class    = Audio/Sink
            audio.channels = 8
            audio.position = [ FL FR FC LFE RL RR SL SR ]
          }
          playback.props = {
            node.passive   = true
            audio.channels = 2
            audio.position = [ FL FR ]
          }
        }
      }
    ]
  '';

  users.users.lantian.extraGroups = [ "audio" ];
}
