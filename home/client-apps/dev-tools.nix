{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
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
    phpWithExtensions

    # Protobuf
    protobuf

    # Python
    black
    conda
    yapf

    # Rust
    rustup

    # Source Control
    mercurialFull
    subversion

    # TOML
    taplo-cli
    taplo-lsp
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
