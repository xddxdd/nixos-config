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
    fakeroot
    file
    findutils
    flex
    gawk
    gcc
    gettext
    gnumake
    groff
    libtool
    m4
    patch
    pkgconf
    texinfo
    which

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

    # Rust
    cargo
    rustc
  ];
}
