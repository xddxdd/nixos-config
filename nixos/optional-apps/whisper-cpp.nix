{ pkgs, lib, ... }:
let
  whisper-cpp = pkgs.whisper-cpp.override { cudaSupport = true; };

  model = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin";
    hash = "sha256-H8cPd0046xaZk6w5Huo1fvR8iHV+9y7llDh5t+jivGk=";
  };

  whisper-v3 = pkgs.runCommand "whisper-v3" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe whisper-cpp} $out/bin/whisper-v3 \
      --add-flags "-m ${model}"
  '';
in
{
  environment.systemPackages = [
    whisper-cpp
    whisper-v3
  ];
}
