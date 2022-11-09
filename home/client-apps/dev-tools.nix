{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
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

    # Lua
    luajit

    # Nix
    flake.agenix.packages."${system}".agenix
    nil
    nixfmt
    nixpkgs-fmt
    nodePackages.node2nix
    rnix-lsp

    # NodeJS
    nodejs
    nodePackages.npm

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

  ] ++ (if pkgs.stdenv.isx86_64 then [
    # Kernel
    lantianCustomized.linux-xanmod-lantian-lto.dev
  ] else [
    # Kernel
    linux_latest.dev
  ]);

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
