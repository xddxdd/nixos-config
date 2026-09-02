{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.audio-cpp-cuda
  ];
}
