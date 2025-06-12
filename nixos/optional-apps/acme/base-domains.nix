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
    ]
    ++ (builtins.map mkLetsEncryptWildcardCert hostSubdomains)
  );
}
