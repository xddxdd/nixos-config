{ pkgs, ... }:
{
  # eMudhra intermediate-key compromise (Mozilla advisory 2026-10-20).
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
    "emSign Root CA - C1"
    "emSign ECC Root CA - C3"
  ];

  security.pki.certificateFiles = [ pkgs.dn42-cacert ];
}
