{
  pkgs,
  lib,
  ...
}: {
  eval = import ./eval.nix {inherit pkgs lib;};
  inherit
    (import ./records.nix {inherit pkgs lib;})
    A
    AAAA
    ALIAS
    CAA
    CNAME
    DS
    IGNORE
    MX
    NAMESERVER
    NS
    PTR
    SRV
    SSHFP
    TLSA
    TXT
    SSHFP_RSA_SHA1
    SSHFP_RSA_SHA256
    SSHFP_ED25519_SHA1
    SSHFP_ED25519_SHA256
    ;
}
