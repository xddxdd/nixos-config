{
  stdenvNoCC,
  fetchurl,
  nur-xddxdd,
  iconv,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "dnyjzsxj";
  version = "1.0.0";

  src = fetchurl {
    url = "https://us-central-1.telnyxstorage.com/lantian-public/dnyjzsxj.chm";
    sha256 = "11svflzscbanly6hgk8gxkdsl9n428apc5z565sdgx0vq9355ash";
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
