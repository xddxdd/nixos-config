{ inputs, ... }:
final: prev: {
  dn42-peerfinder = final.callPackage ../pkgs/dn42-peerfinder { };
  knot-exporter = final.callPackage ../pkgs/knot-exporter {
    source = (final.callPackage ../helpers/_sources/generated.nix { }).knot-exporter-go;
  };
  kwin-effects-better-blur-dx =
    inputs.kwin-effects-better-blur-dx.packages."${prev.stdenv.hostPlatform.system}".default;
  lantian-secrets = final.callPackage ../pkgs/lantian-secrets { };
  markdown-apa7th-docx =
    inputs.markdown-apa7th-docx.packages."${prev.stdenv.hostPlatform.system}".default;
  nixfmt-rs = inputs.nixfmt-rs.packages."${prev.stdenv.hostPlatform.system}".default;
  never-gonna = inputs.never-gonna-rust.packages."${prev.stdenv.hostPlatform.system}".default;
  picoforge = inputs.picoforge.packages."${prev.stdenv.hostPlatform.system}".picoforge;
  web-compressor = final.callPackage ../pkgs/web-compressor { };
  wine-tkg = inputs.nix-gaming.packages."${prev.stdenv.hostPlatform.system}".wine-tkg;
}
