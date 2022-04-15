{ inputs, nixpkgs, ... }:

final: prev: rec {
  # 168071
  calibre = prev.calibre.override {
    python3Packages = prev.python3Packages // {
      apsw = prev.python3Packages.apsw.overridePythonAttrs (old: {
        version = "3.38.1-r1";
        sha256 = "sha256-pbb6wCu1T1mPlgoydB1Y1AKv+kToGkdVUjiom2vTqf4=";
        checkInputs = [ ];
      });
    };
  };

  # 167072
  calibre-web = prev.calibre-web.overridePythonAttrs (old:
    let
      advocate = prev.python3Packages.buildPythonPackage rec {
        pname = "advocate";
        version = "1.0.0";
        src = prev.python3Packages.fetchPypi {
          inherit pname version;
          sha256 = "sha256-G/EXDkEzQnmZZYAynFlOAXVAqw6vehUjI+dD8KhaNT0=";
        };
        propagatedBuildInputs = with prev.python3Packages; [
          requests
          ndg-httpsclient
          netifaces
        ];
        doCheck = false;
      };
    in
    rec {
      version = "0.6.18";
      src = prev.fetchFromGitHub {
        owner = "janeczku";
        repo = "calibre-web";
        rev = version;
        sha256 = "sha256-KjmpFetNhNM5tL34e/Pn1i3hc86JZglubSMsHZWu198=";
      };

      propagatedBuildInputs = old.propagatedBuildInputs ++ [ advocate ];

      postPatch = old.postPatch + ''
        substituteInPlace setup.cfg \
          --replace "cps = calibreweb:main" "calibre-web = calibreweb:main" \
          --replace "flask-wtf>=0.14.2,<1.1.0" "flask-wtf>=0.14.2" \
          --replace "lxml>=3.8.0,<4.9.0" "lxml>=3.8.0" \
          --replace "PyPDF3>=1.0.0,<1.0.7" "PyPDF3>=1.0.0" \
          --replace "requests>=2.11.1,<2.28.0" "requests" \
          --replace "unidecode>=0.04.19,<1.4.0" "unidecode>=0.04.19"
      '';
    });
}
