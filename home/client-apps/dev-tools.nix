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
    haskellPackages.Cabal_3_6_2_0
    stack

    # Jsonnet
    jsonnet

    # LaTeX
    texlive.combined.scheme-full

    # Lua
    luajit

    # NodeJS
    nodejs
    nodePackages.npm

    # PHP
    phpWithExtensions

    # Protobuf
    protobuf

    # Python
    python3Packages.pip

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
    linux-xanmod-lantian.dev
  ] else [
    # Kernel
    linux_latest.dev
  ]);

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
