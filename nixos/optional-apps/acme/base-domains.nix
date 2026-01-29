{
  LT,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (pkgs.callPackage ./common.nix { inherit config; })
    mkLetsEncryptWildcardCert
    mkZeroSSLWildcardCert
    ;

  hostSubdomains = lib.mapAttrsToList (n: v: "${n}.xuyh0120.win") LT.hosts;
in
{
  security.acme.certs = lib.mergeAttrsList (
    [
      (mkLetsEncryptWildcardCert "lantian.pub")
      (mkLetsEncryptWildcardCert "xuyh0120.win")
      (mkLetsEncryptWildcardCert "56631131.xyz")
      (mkLetsEncryptWildcardCert "ltn.pw")
      (mkZeroSSLWildcardCert "lantian.pub")
      (mkZeroSSLWildcardCert "xuyh0120.win")
      (mkZeroSSLWildcardCert "56631131.xyz")
      (mkZeroSSLWildcardCert "ltn.pw")
    ]
    ++ (builtins.map mkLetsEncryptWildcardCert hostSubdomains)
    ++ (builtins.map mkZeroSSLWildcardCert hostSubdomains)
  );
}
