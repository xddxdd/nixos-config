{ pkgs, ... }:
{
  security.pki.certificateFiles = [
    # DN42
    (pkgs.fetchurl {
      url = "https://aur.archlinux.org/cgit/aur.git/plain/dn42.crt?h=ca-certificates-dn42";
      sha256 = "12w9d5qdk8b7044arm130gffy21c8pvakawi6m99m5pdvw5ixhy2";
    })

    # CAcert.org
    (pkgs.fetchurl {
      url = "http://www.cacert.org/certs/root_X0F.crt";
      sha256 = "0rjagkwwa7lqk7xmmvcv3yyda45lwcv1d3zzl5rns42b0h48lbbh";
    })
    (pkgs.fetchurl {
      url = "http://www.cacert.org/certs/CAcert_Class3Root_x14E228.crt";
      sha256 = "1sqbs2zwxzljsy3161bkc4ai0a5vcqk1a9hblljsggdjy138sqg6";
    })
  ];
}
