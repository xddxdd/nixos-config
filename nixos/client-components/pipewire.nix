{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  rtprioConf = builtins.listToAttrs (
    builtins.map
    (n:
      lib.nameValuePair "pipewire/${n}.conf.d/rtprio.conf" {
        text = builtins.toJSON {
          "context.modules" = [
            {
              name = "libpipewire-module-rt";
              args = {
                "nice.level" = -11;
                "rt.prio" = 88;
                "rt.time.soft" = realtimeLimitUS;
                "rt.time.hard" = realtimeLimitUS;
              };
              flags = ["ifexists" "nofail"];
            }
          ];
        };
      })
    [
      "client-rt"
      "client"
      "jack"
      "pipewire-pulse"
      "pipewire"
    ]
  );

  resampleQualityConf = builtins.listToAttrs (
    builtins.map
    (n:
      lib.nameValuePair "pipewire/${n}.conf.d/resample-quality.conf" {
        text = builtins.toJSON {
          "stream.properties"."resample.quality" = 10;
        };
      })
    [
      "client-rt"
      "client"
      "jack"
      "pipewire-pulse"
    ]
  );

  mkVirtualSurroundSink = name: hrir: let
    gain = 0.5;
  in ''
    { name = libpipewire-module-filter-chain
      args = {
        node.name        = "effect_output.virtual-surround-${LT.sanitizeName name}"
        node.description = "Virtual Surround (${name})"
        media.name       = "Virtual Surround (${name})"
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
            # Reduce gain to prevent clipping
            { type = builtin label = convolver name = convFL_L config = { filename = "${hrir}" channel =  0 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convFL_R config = { filename = "${hrir}" channel =  1 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convSL_L config = { filename = "${hrir}" channel =  2 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convSL_R config = { filename = "${hrir}" channel =  3 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convRL_L config = { filename = "${hrir}" channel =  4 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convRL_R config = { filename = "${hrir}" channel =  5 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convFC_L config = { filename = "${hrir}" channel =  6 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convFR_R config = { filename = "${hrir}" channel =  7 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convFR_L config = { filename = "${hrir}" channel =  8 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convSR_R config = { filename = "${hrir}" channel =  9 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convSR_L config = { filename = "${hrir}" channel = 10 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convRR_R config = { filename = "${hrir}" channel = 11 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convRR_L config = { filename = "${hrir}" channel = 12 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convFC_R config = { filename = "${hrir}" channel = 13 gain = ${builtins.toString gain} } }

            # treat LFE as FC
            { type = builtin label = convolver name = convLFE_L config = { filename = "${hrir}" channel =  6 gain = ${builtins.toString gain} } }
            { type = builtin label = convolver name = convLFE_R config = { filename = "${hrir}" channel = 13 gain = ${builtins.toString gain} } }

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
  '';

  realtimeLimitUS = 5000000;
in {
  security.rtkit.enable = true;
  systemd.services.rtkit-daemon.serviceConfig.ExecStart = [
    "" # Override command in rtkit package's service file
    "${pkgs.rtkit}/libexec/rtkit-daemon --rttime-usec-max=${builtins.toString realtimeLimitUS}"
  ];

  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;

    wireplumber.enable = true;
  };

  environment.etc =
    rtprioConf
    // resampleQualityConf
    // {
      "pipewire/pipewire.conf.d/noise-cancelling.conf".text = builtins.toJSON {
        "context.modules" = [
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

      # For some reason PipeWire fails to start when this is converted to JSON
      "pipewire/pipewire.conf.d/surround.conf".text = ''
        context.modules = [
          ${mkVirtualSurroundSink "Dolby Atmos" "${pkgs.hesuvi-hrir}/atmos.wav"}
          ${mkVirtualSurroundSink "DTS Headphone:X" "${pkgs.hesuvi-hrir}/dtshx.wav"}
          ${mkVirtualSurroundSink "Windows Sonic" "${pkgs.hesuvi-hrir}/sonic.wav"}
        ]
      '';

      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
        bluez_monitor.properties = {
        	["bluez5.enable-sbc-xq"] = true,
        	["bluez5.enable-msbc"] = true,
        	["bluez5.enable-hw-volume"] = true,
        	["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';
    };

  users.users.lantian.extraGroups = ["audio"];
}
