{
  LT,
  pkgs,
  ...
}:
let
  configDir = pkgs.writeTextDir "config.json" (
    builtins.toJSON {
      "port" = LT.port.Pyison;
      "random-seed" = 2547;
      "document-root" = "/";

      "fake-image-dir" = [ "images" ];
      "fake-css-dir" = [ "css" ];

      "spacing-characters" = [
        "_"
        "-"
        "%20"
      ];
      "unsafe-characters" = [
        "'"
        "`"
      ];

      "robots-txt" = "assets/robots.txt";
      "html-templates" = [ "assets/template.html" ];
      "css-files" = [ "assets/style.css" ];
      "images" = {
        "ico" = [ "assets/logo.ico" ];
        "jpg" = [ "assets/logo.jpg" ];
        "png" = [ "assets/logo.png" ];
      };

      "remove-from-stop-words" = [
        "ll"
        "s"
        "t"
        "don"
        "d"
        "m"
        "o"
        "re"
        "ve"
        "y"
        "ain"
        "aren"
        "couldn"
        "didn"
        "doesn"
        "hadn"
        "hasn"
        "haven"
        "isn"
        "ma"
        "mightn"
        "needn"
        "shan"
        "shouldn"
        "wasn"
        "weren"
        "won"
        "wouldn"
      ];
    }
  );
in
{
  virtualisation.oci-containers.containers.pyison = {
    image = "ghcr.io/jonaslong/pyison:main";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    ports = [ "127.0.0.1:${LT.portStr.Pyison}:${LT.portStr.Pyison}" ];
    volumes = [ "${configDir}:/var/www/config:ro" ];
  };

  lantian.nginxVhosts."posts.lantian.pub" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Pyison}";
      };
    };

    sslCertificate = "zerossl-lantian.pub";
  };
}
