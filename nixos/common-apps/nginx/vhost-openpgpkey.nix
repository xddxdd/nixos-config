{ pkgs, ... }:
let
  # builtins.path copies the keys to their own store path; a plain
  # "${gpgKeysDir}/${name}" string is a sub-path of the flake source and would
  # not be mounted into the build sandbox
  gpgKeys = builtins.path {
    path = ../../../helpers/gpg-keys;
    name = "gpg-keys";
  };

  # OpenPGP Web Key Directory, advanced method. GnuPG probes
  # openpgpkey.<domain> first and, if it resolves, requests
  # /.well-known/openpgpkey/<domain>/hu/<zb32(sha1(localpart))>
  # Regenerate with: gpg --with-wkd-hash --list-keys lantian@lantian.pub
  wkdHash = "mpbckm33hpbq3q76tzbxqe6bo5gicy4z";

  wkdTree = pkgs.runCommand "wkd-lantian.pub" { } ''
    install -d $out/.well-known/openpgpkey/lantian.pub/hu
    cat ${gpgKeys}/*.pgp > $out/.well-known/openpgpkey/lantian.pub/hu/${wkdHash}
  '';
in
{
  lantian.nginxVhosts."openpgpkey.lantian.pub" = {
    root = wkdTree;
    sslCertificate = "lets-encrypt-lantian.pub";
    noIndex.enable = true;
  };
}
