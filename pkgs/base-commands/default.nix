{ stdenv }:
stdenv.mkDerivation {
  pname = "base-commands";
  version = "1.0.0";

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    # Keep ELF headers and code in one RX segment; there is no writable data.
    "$CC" -nostdlib -static -no-pie -s -Wl,--build-id=none,-z,noseparate-code \
      -o base-commands ${./start.S}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 base-commands "$out/libexec/base-commands"
    mkdir -p "$out/bin"
    while IFS= read -r command; do
      ln -s ../libexec/base-commands "$out/bin/$command"
    done < ${./commands.txt}
    runHook postInstall
  '';

  meta = {
    description = "Silent failing decoys for a curated set of common Debian command names";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
