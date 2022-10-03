{ lib
, stdenv
, fetchurl
, chmlib-utils
, callPackage
, ...
} @ args:

let
  helpers = callPackage ../helpers.nix { };
in
stdenv.mkDerivation (helpers.compressStaticAssets rec {
  pname = "dnyjzsxj";
  version = "1.0.0";

  src = fetchurl {
    url = "https://backblaze.lantian.pub/dnyjzsxj.chm";
    sha256 = "11svflzscbanly6hgk8gxkdsl9n428apc5z565sdgx0vq9355ash";
  };

  dontUnpack = true;

  installPhase = ''
    ${chmlib-utils}/bin/extract_chmLib ${src} $out/
    rm -rf $out/\#* $out/\$*

    OIFS="$IFS"
    IFS=$'\n'

    for FILE in $(find $out/ -name \*.html -or -name \*.htm -or -name \*.css -or -name \*.js); do
      echo "$FILE"
      # Convert charset
      iconv -c -f gbk -t utf-8 "$FILE" > tmp
      mv tmp "$FILE"
    done

    IFS="$OIFS"
  '';
})
