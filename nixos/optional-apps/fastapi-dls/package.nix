{
  lib,
  stdenv,
  fetchurl,
  python3,
  makeWrapper,
  ...
}: let
  python = python3.withPackages (p:
    with p; [
      dateutils
      fastapi
      markdown
      pycryptodome
      python-dotenv
      python-jose
      sqlalchemy
      uvicorn
    ]);
in
  stdenv.mkDerivation {
    pname = "fastapi-dls";
    version = "1.0";
    src = fetchurl {
      url = "https://private.xuyh0120.win/fastapi-dls.tar.gz";
      sha256 = "0v3nz1bp4zsdfc23pk77wfqrnnhm5sa7wklfilix3diplr0846qp";
    };

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      mkdir -p $out/bin $out/opt
      cp -r * $out/opt/

      sed -i "s#\\.\\./#$out/opt/#g" $out/opt/app/main.py

      makeWrapper ${python}/bin/python $out/bin/fastapi-dls \
        --add-flags "-m" \
        --add-flags "uvicorn" \
        --add-flags "--app-dir" \
        --add-flags "$out/opt/app" \
        --add-flags "main:app" \
    '';
  }
