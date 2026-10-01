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

  # Wildcard certs for old host names, so the replacing host can serve
  # 301 redirects on their subdomains (see vhost-replaced-hosts.nix)
  replacedHostSubdomains = builtins.map (n: "${n}.xuyh0120.win") (
    builtins.attrNames LT.replacedHosts
  );
in
{
  security.acme.certs = lib.mergeAttrsList (
    [
      (mkLetsEncryptWildcardCert "lantian.pub")
      (mkLetsEncryptWildcardCert "xuyh0120.win")
      (mkLetsEncryptWildcardCert "56631131.xyz")
      (mkLetsEncryptWildcardCert "ltn.pw")
      (mkLetsEncryptWildcardCert "xn--gmqs02au1c935d.pub")
      (mkZeroSSLWildcardCert "lantian.pub")
      (mkZeroSSLWildcardCert "xuyh0120.win")
      (mkZeroSSLWildcardCert "56631131.xyz")
      (mkZeroSSLWildcardCert "ltn.pw")
      (mkZeroSSLWildcardCert "xn--gmqs02au1c935d.pub")

      # ATproto PDS
      (mkLetsEncryptWildcardCert "lantian.pub")
      (mkZeroSSLWildcardCert "at.lantian.pub")
    ]
    ++ (builtins.map mkLetsEncryptWildcardCert hostSubdomains)
    ++ (builtins.map mkZeroSSLWildcardCert hostSubdomains)
    ++ (builtins.map mkLetsEncryptWildcardCert replacedHostSubdomains)
    ++ (builtins.map mkZeroSSLWildcardCert replacedHostSubdomains)
  );
}
