{ inputs, ... }:
final: prev: {
  asrock-fan-control = final.callPackage ../pkgs/asrock-fan-control { };
  asterisk-never-gonna = final.callPackage ../pkgs/asterisk-never-gonna { };
  base-commands = final.callPackage ../pkgs/base-commands { };
  dn42-peerfinder = final.callPackage ../pkgs/dn42-peerfinder { };
  lantian-secrets = final.callPackage ../pkgs/lantian-secrets { };
  luciole = inputs.luciole.packages."${prev.stdenv.hostPlatform.system}".default;
  markdown-apa7th-docx =
    inputs.markdown-apa7th-docx.packages."${prev.stdenv.hostPlatform.system}".default;
  nix-tree-rs = inputs.nix-tree-rs.packages."${prev.stdenv.hostPlatform.system}".default;
  nixfmt-rs = inputs.nixfmt-rs.packages."${prev.stdenv.hostPlatform.system}".default;
  picoforge = inputs.picoforge.packages."${prev.stdenv.hostPlatform.system}".picoforge;
  port-audit = final.callPackage ../pkgs/port-audit { };
  sakura-share = final.callPackage ../pkgs/sakura-share { };
  smfc = final.callPackage ../pkgs/smfc { };
  web-compressor = final.callPackage ../pkgs/web-compressor { };
  wine-tkg = inputs.nix-gaming.packages."${prev.stdenv.hostPlatform.system}".wine-tkg;
}
