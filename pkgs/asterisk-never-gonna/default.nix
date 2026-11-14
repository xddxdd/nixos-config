{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  asterisk,
}:
let
  audioSource = fetchFromGitHub {
    owner = "xddxdd";
    repo = "never-gonna-rust";
    rev = "e5d17fcdca5478fde0cdf7117b307142a15ab122";
    hash = "sha256-TgpFMU3o91WdnczDB7sGPke3G7JZBl+9QAt4NXX7iSY=";
  };
in
stdenv.mkDerivation {
  pname = "asterisk-never-gonna";
  version = "0.1.0";
  src = ./.;
  strictDeps = true;

  nativeBuildInputs = [ python3 ];
  buildInputs = [ asterisk ];
  env.MUSIC_DIR = "${audioSource}/music";
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    python3 tools/generate_audio.py "$MUSIC_DIR" never_gonna_audio.h
    $CC -std=gnu11 -O2 -Wall -Wextra -fPIC -shared -pthread \
      -I${lib.getDev asterisk}/include \
      -DAST_MODULE=\"app_never_gonna\" \
      -DAST_MODULE_SELF_SYM=__internal_app_never_gonna_self \
      app_never_gonna.c -o app_never_gonna.so
    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    python3 -m unittest discover -s tests -v
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 app_never_gonna.so "$out/lib/asterisk/modules/app_never_gonna.so"
    runHook postInstall
  '';

  meta = {
    description = "Gapless Markov-chain song player for Asterisk";
    # GPL applies to the code, not to the embedded third-party recordings.
    license = [
      lib.licenses.gpl2Only
      lib.licenses.unfree
    ];
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = lib.platforms.linux;
  };
}
