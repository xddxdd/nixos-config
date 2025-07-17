{
  pkgs,
  LT,
  config,
  ...
}:
let
  nftRules = pkgs.callPackage ./nft-rules.nix { inherit LT config; };
in
{
  networking.nftables = {
    enable = true;
    tables.lantian = {
      family = "inet";
      content = nftRules;
    };
  };
}
