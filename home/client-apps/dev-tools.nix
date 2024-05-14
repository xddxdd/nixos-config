{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
let
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

  # https://discourse.nixos.org/t/nix-flamegraph-or-profiling-tool/33333
  nix-profiling =
    let
      stackCollapse = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nix/master/contrib/stack-collapse.py";
        sha256 = "sha256:0mi9cf3nx7xjxcrvll1hlkhmxiikjn0w95akvwxs50q270pafbjw";
      };
    in
    pkgs.writeShellScriptBin "nix-profiling" ''
      nix eval -vvvvvvvvvvvvvvvvvvvv --raw --option trace-function-calls true $1 1>/dev/null 2> nix-function-calls.trace
      python ${stackCollapse} nix-function-calls.trace > nix-function-calls.folded
      ${pkgs.inferno}/bin/inferno-flamegraph nix-function-calls.folded > nix-function-calls.svg
      echo "nix-function-calls.svg"
    '';

  pythonCustomized = pkgs.python3Full.withPackages (
    p:
    with p;
    (
      if pkgs.stdenv.isx86_64 then
        [
          autopep8
          numpy
          matplotlib
        ]
      else
        [ ]
    )
    ++ [
      dnspython
      pip
      requests
    ]
  );

  linkzoneAdb = pkgs.writeShellScriptBin "linkzone-adb" ''
    exec ${pkgs.sg3_utils}/bin/sg_raw "$1" 16 f9 00 00 00 00 00 00 00 00 00 00 00 00 00 00 -v
  '';
in
{
  home.packages = with pkgs; [
    # Bash
    dos2unix
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
    go-outline
    go-tools
    gomodifytags
    gopls
    gotests
    impl

    # Jsonnet
    jsonnet

    # Kubernetes
    arkade
    faas-cli # OpenFaaS
    ktop
    kubectl
    kubernetes-helm
    lens

    # LaTeX
    texlive.combined.scheme-full

    # Linux headers
    LT.config.boot.kernelPackages.kernel.dev

    # Lua
    luajit

    # Nix
    inputs.agenix.packages."${system}".agenix
    alejandra
    nil
    nix-output-monitor
    nix-prefetch
    nix-prefetch-scripts
    nix-profiling
    nix-store-add
    nixd
    nixfmt-rfc-style
    nixpkgs-fmt
    nodePackages.node2nix
    nurl

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
    subversion

    # Terraform
    terraform
    terranix

    # TOML
    taplo-cli
    taplo-lsp

    # Others
    dhcpcd
    ghidra
    linkzoneAdb
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.go = {
    enable = true;
    goBin = ".local/bin";
    goPath = ".local/share/go";
  };

  programs.pyenv.enable = true;
  programs.pylint.enable = true;
}
