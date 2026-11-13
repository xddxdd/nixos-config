{ inputs, ... }:
final: prev: {
  dn42-peerfinder = final.callPackage ../pkgs/dn42-peerfinder { };
  lantian-secrets = final.callPackage ../pkgs/lantian-secrets { };
  markdown-apa7th-docx =
    inputs.markdown-apa7th-docx.packages."${prev.stdenv.hostPlatform.system}".default;
  nix-tree-rs = inputs.nix-tree-rs.packages."${prev.stdenv.hostPlatform.system}".default;
  nixfmt-rs = inputs.nixfmt-rs.packages."${prev.stdenv.hostPlatform.system}".default;
  never-gonna = inputs.never-gonna-rust.packages."${prev.stdenv.hostPlatform.system}".default;
  picoforge = inputs.picoforge.packages."${prev.stdenv.hostPlatform.system}".picoforge;
  port-audit = final.callPackage ../pkgs/port-audit { };
  web-compressor = final.callPackage ../pkgs/web-compressor { };
  wine-tkg = inputs.nix-gaming.packages."${prev.stdenv.hostPlatform.system}".wine-tkg;
}
