{
  pkgs,
  ...
}:
{
  imports = [ ./mysql.nix ];

  services.wordpress = {
    webserver = "nginx";
    sites."wp.xuyh0120.win" = {
      database = {
        createLocally = true;
        name = "wordpress";
      };
      settings.WPLANG = "zh_CN";
      languages = [
        (pkgs.stdenv.mkDerivation {
          name = "language-zh_CN";
          src = pkgs.fetchurl {
            url = "https://zh.wordpress.org/wordpress-${pkgs.wordpress.version}-zh_CN.tar.gz";
            sha256 = "sha256-oAzo/+6mEk4+CYXGN/a61An3GpnSfnfQka56HchhXsE=";
          };
          installPhase = "mkdir -p $out; cp -r ./wp-content/languages/* $out/";
        })
      ];
    };
  };

  lantian.nginxVhosts."wp.xuyh0120.win" = {
    sslCertificate = "zerossl-xuyh0120.win";
  };
}
