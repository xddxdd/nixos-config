{ pkgs, lib, ... }:
let
  sanitize =
    let
      allowed = lib.lowerChars ++ lib.upperChars ++ lib.stringToCharacters ("0123456789" + "+-");
    in
    lib.stringAsChars (k: if builtins.elem k allowed then k else "");

  hesuviHrirInfo = builtins.listToAttrs (
    builtins.map
      (
        line:
        let
          splitted = lib.splitString ";" line;
          name = sanitize (builtins.elemAt splitted 0);
        in
        lib.nameValuePair name (builtins.elemAt splitted 1)
      )
      (
        builtins.filter (lib.hasInfix ";") (
          lib.splitString "\r\n" (builtins.readFile "${pkgs.hesuvi-hrir}/info.csv")
        )
      )
  );

  mkVirtualSurroundSink =
    hrir:
    let
      name = hesuviHrirInfo."${hrir}";
      gain = 1;
    in
    pkgs.writeTextFile {
      name = "pipewire-surround-${hrir}";
      # For some reason PipeWire fails to start when this is converted to JSON
      text = ''
        context.modules = [
          { name = libpipewire-module-filter-chain
            args = {
              node.name        = "effect_output.virtual-surround-${hrir}"
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
                  { type = builtin label = convolver name = convFL_L config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel =  0 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convFL_R config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel =  1 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convSL_L config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel =  2 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convSL_R config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel =  3 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convRL_L config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel =  4 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convRL_R config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel =  5 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convFC_L config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel =  6 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convFR_R config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel =  7 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convFR_L config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel =  8 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convSR_R config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel =  9 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convSR_L config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel = 10 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convRR_R config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel = 11 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convRR_L config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel = 12 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convFC_R config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel = 13 gain = ${builtins.toString gain} } }

                  # treat LFE as FC
                  { type = builtin label = convolver name = convLFE_L config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel =  6 gain = ${builtins.toString gain} } }
                  { type = builtin label = convolver name = convLFE_R config = { filename = "${pkgs.hesuvi-hrir}/${hrir}.wav" channel = 13 gain = ${builtins.toString gain} } }

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
      destination = "/share/pipewire/pipewire.conf.d/surround-${hrir}.conf";
    };
in
{
  # environment.etc."hrir".text = builtins.toJSON hesuviHrirInfo;
  services.pipewire.configPackages = builtins.map mkVirtualSurroundSink [
    "atmos"
    "dtshx"
    "sonic+"
    "razer"
  ];
}
