{
  LT,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (pkgs.callPackage ./common.nix { inherit config; })
    mkZeroSSLWildcardCert
    ;

  hostSubdomains = lib.mapAttrsToList (n: v: "${n}.xuyh0120.win") LT.hosts;
in
{
  security.acme.certs = lib.mergeAttrsList (
    [
      (mkZeroSSLWildcardCert "lantian.pub")
      (mkZeroSSLWildcardCert "xuyh0120.win")
      (mkZeroSSLWildcardCert "56631131.xyz")
      (mkZeroSSLWildcardCert "ltn.pw")
    ]
    ++ (builtins.map mkZeroSSLWildcardCert hostSubdomains)
  );
}
