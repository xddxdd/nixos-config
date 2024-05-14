{ pkgs, ... }:
{
  security.pki.certificateFiles = [
    # DN42
    (pkgs.fetchurl {
      url = "https://aur.archlinux.org/cgit/aur.git/plain/dn42.crt?h=ca-certificates-dn42";
      sha256 = "12w9d5qdk8b7044arm130gffy21c8pvakawi6m99m5pdvw5ixhy2";
    })

    # NeoNetwork
    (pkgs.fetchurl {
      url = "https://github.com/NeoCloud/NeoNetwork/raw/82420bf02fde9e224f697d49e1044fe55b176644/ca/neonetwork.crt";
      sha256 = "1mz5w1j2ss5kilc1x11ywvmgnk7mmmiljncamr1gckypm9cqd31f";
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

    # Unblock Netease Music
    (pkgs.fetchurl {
      url = "https://github.com/UnblockNeteaseMusic/server/raw/enhanced/ca.crt";
      sha256 = "1yvlyqrqgcyb3xnb06p1mkzh9k31v411i501a14vm1s22x1nv64d";
    })
  ];
}
