{ pkgs, dns, ... }:

with dns;

{ prefix, target }:
let
  prefixSplitted = pkgs.lib.splitString "/" prefix;
  prefixIP = builtins.elemAt prefixSplitted 0;

  commonPoem = import ./common-poem.nix { inherit pkgs dns; };
in
rec {
  domain = prefix;
  reverse = true;
  providers = [ "henet" ];
  records =
    [
      (PTR { name = "*"; inherit target; })
      (PTR { name = "${prefixIP}1"; inherit target; })
    ]
    ++ (commonPoem "${prefixIP}" 2);
}
