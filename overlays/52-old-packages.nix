{ inputs, ... }:
final: prev:
let
  mv = inputs.nixpkgs-multiverse.multiverse.${final.stdenv.hostPlatform.system};
in
{
  inherit (mv.at "26.05") linphone linphonePackages;
}
