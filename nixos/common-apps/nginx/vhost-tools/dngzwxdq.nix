{
  stdenvNoCC,
  fetchurl,
  chmlib,
  iconv,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "dngzwxdq";
  version = "4.5.0";

  src = fetchurl {
    url = "https://us-central-1.telnyxstorage.com/lantian-public/dngzwxdq.chm";
    sha256 = "0h05zfph4shviwrib283k3w565nn9haf7pa9rr6in3zb5vb1xnf8";
  };

  nativeBuildInputs = [
    chmlib
    iconv
  ];

  dontUnpack = true;

  installPhase = ''
    extract_chmLib $src $out/
    rm -rf $out/\#* $out/\$*

    OIFS="$IFS"
    IFS=$'\n'

    for FILE in $(find $out/ -name \*.html -or -name \*.htm -or -name \*.css -or -name \*.js); do
      echo "$FILE"
      # Convert charset
      iconv -c -f gbk -t utf-8 "$FILE" > tmp || cp "$FILE" tmp
      mv tmp "$FILE"
      sed -i "s#http://www.163164.com/js/pc3.js##g" "$FILE"
    done

    IFS="$OIFS"
  '';
}
