{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  # https://nixos.wiki/wiki/Cheatsheet#Adding_files_to_the_store
  nix-store-add = pkgs.writeShellScriptBin "nix-store-add" ''
    if [ -z "$1" ]; then
      echo "Usage: nix-store-add path/to/file"
      exit 1
    fi

    sudo unshare -m bash -x <<EOF
    hash=\$(nix-hash --type sha256 --flat --base32 $1)
    storepath=\$(nix-store --print-fixed-path sha256 \$hash \$(basename $1))
    mount -o remount,rw /nix/store
    cp $1 \$storepath
    printf "\$storepath\n\n0\n" | nix-store --register-validity --reregister
    EOF
  '';

  pythonCustomized = pkgs.python3Full.withPackages (p:
    with p;
      (
        if pkgs.stdenv.isx86_64
        then [
          autopep8
          numpy
          matplotlib
        ]
        else []
      )
      ++ [
        dnspython
        pip
        requests
      ]);
in {
  home.packages = with pkgs; [
    # Bash
    shellcheck

    # C
    autoconf
    automake
    binutils
    bison
    clang-analyzer
    clang-tools
    cmake
    cppcheck
    fakeroot
    file
    findutils
    flex
    gawk
    gcc
    gdb
    gettext
    gnumake
    groff
    libtool
    lldb
    m4
    patch
    pkgconf
    texinfo
    which

    # Fly.io
    flyctl

    # FPGA
    vivado-2022_2

    # Golang
    delve
    go
    go-outline
    go-tools
    go2nix
    gomodifytags
    gopls
    gotests
    impl

    # Haskell
    ghc
    haskell-language-server
    haskellPackages.Cabal_3_6_3_0
    stack

    # Jsonnet
    jsonnet

    # Kubernetes
    arkade
    faas-cli # OpenFaaS
    kubectl
    kubernetes-helm

    # LaTeX
    texlive.combined.scheme-full

    # Linux headers
    LT.config.boot.kernelPackages.kernel.dev

    # Lua
    luajit

    # Nix
    inputs.agenix.packages."${system}".agenix
    alejandra
    fup-repl
    nil
    nix-prefetch
    nix-store-add
    nixfmt
    nixpkgs-fmt
    nodePackages.node2nix
    nurl
    rnix-lsp

    # NodeJS
    nodejs
    nodePackages.npm

    # Packaging
    dpkg

    # PHP
    composer2nix
    phpPackages.composer
    phpWithExtensions

    # Protobuf
    protobuf

    # Python
    (lib.lowPrio pythonCustomized)
    black
    conda
    micromamba
    virtualenv
    yapf

    # Rust
    rustup

    # Source Control
    mercurialFull
    subversion

    # Terraform
    terraform
    terranix

    # TOML
    taplo-cli
    taplo-lsp
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
