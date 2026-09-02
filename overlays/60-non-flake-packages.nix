{ inputs, ... }:
final: prev: {
  audio-cpp-cuda = inputs.audio-cpp.packages."${prev.stdenv.hostPlatform.system}".cuda;
  kwin-effects-better-blur-dx =
    inputs.kwin-effects-better-blur-dx.packages."${prev.stdenv.hostPlatform.system}".default;
  markdown-apa7th-docx =
    inputs.markdown-apa7th-docx.packages."${prev.stdenv.hostPlatform.system}".default;
  nixfmt-rs = inputs.nixfmt-rs.packages."${prev.stdenv.hostPlatform.system}".default;
  never-gonna = inputs.never-gonna-rust.packages."${prev.stdenv.hostPlatform.system}".default;
  picoforge = inputs.picoforge.packages."${prev.stdenv.hostPlatform.system}".picoforge;
  wine-tkg = inputs.nix-gaming.packages."${prev.stdenv.hostPlatform.system}".wine-tkg;
}
