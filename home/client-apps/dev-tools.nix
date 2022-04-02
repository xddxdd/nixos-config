{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  home.packages = with pkgs; [
    # C
    autoconf
    automake
    binutils
    bison
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

    # LaTeX
    texlive.combined.scheme-full

    # NodeJS
    nodejs
    nodePackages.npm

    # PHP
    phpWithExtensions

    # Python
    python3Packages.pip

    # Rust
    rustup
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
