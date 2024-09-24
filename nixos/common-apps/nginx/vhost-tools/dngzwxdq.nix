{
  stdenvNoCC,
  fetchurl,
  nur-xddxdd,
  iconv,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "dngzwxdq";
  version = "4.5.0";

  src = fetchurl {
    url = "https://backblaze.lantian.pub/dngzwxdq.chm";
    sha256 = "0h05zfph4shviwrib283k3w565nn9haf7pa9rr6in3zb5vb1xnf8";
  };

  nativeBuildInputs = [
    nur-xddxdd.chmlib-utils
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
      iconv -c -f gbk -t utf-8 "$FILE" > tmp
      mv tmp "$FILE"
    done

    IFS="$OIFS"
  '';
}
