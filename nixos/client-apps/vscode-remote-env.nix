{
  pkgs,
  lib,
  ...
}:
let
  runtimeDependencies = with pkgs; [
    stdenv.cc.libc
    stdenv.cc.cc

    # dotnet
    curl
    icu
    libunwind
    libuuid
    lttng-ust
    openssl
    zlib

    # mono
    krb5
  ];

  nodejsFHS = pkgs.buildFHSEnv {
    name = "node";
    targetPkgs = _: runtimeDependencies;
    extraBuildCommands = ''
      if [[ -d /usr/lib/wsl ]]; then
        # Recursively symlink the lib files necessary for WSL
        # to properly function under the FHS compatible environment.
        # The -s stands for symbolic link.
        cp -rsHf /usr/lib/wsl usr/lib/wsl
      fi
    '';
    runScript = lib.getExe pkgs.nodejs;
    meta = {
      description = ''
        Wrapped variant of Node.js which launches in an FHS compatible envrionment,
        which should allow for easy usage of extensions without Nix-specific modifications.
      '';
    };
  };

  fakePatchelf = pkgs.writeShellScriptBin "patchelf" ''
    LAST_ARG="''${@: -1}"
    rm -f "$LAST_ARG"
    ln -sf ${lib.getExe' nodejsFHS "node"} "$LAST_ARG"
  '';
in
{
  environment.variables = {
    VSCODE_SERVER_CUSTOM_GLIBC_LINKER = "/placeholder/path";
    VSCODE_SERVER_CUSTOM_GLIBC_PATH = "/placeholder/path";
    VSCODE_SERVER_PATCHELF_PATH = "${lib.getExe' fakePatchelf "patchelf"}";
  };
}
