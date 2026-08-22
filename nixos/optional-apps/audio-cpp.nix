{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.audio-cpp.packages."${pkgs.stdenv.hostPlatform.system}".cuda
  ];
}
