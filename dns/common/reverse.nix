{ pkgs, dns, ... }:

with dns;

{ prefix, target }:
let
  prefixSplitted = pkgs.lib.splitString "/" prefix;
  prefixIP = builtins.elemAt prefixSplitted 0;

  poem = import ./poem.nix { inherit pkgs dns; };
in
rec {
  domain = prefix;
  reverse = true;
  registrar = "doh";
  providers = [ "henet" ];
  records = [
    (PTR { name = "*"; inherit target; })
    (PTR { name = "${prefixIP}1"; inherit target; })
    (poem "${prefixIP}" 2)
  ];
}
