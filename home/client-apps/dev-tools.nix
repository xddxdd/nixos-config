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

  nix-profiling = pkgs.writeShellScriptBin "nix-profiling" ''
    rm -f nix.profile flamegraph.svg
    nix eval --no-eval-cache \
      --option eval-profiler flamegraph \
      --option eval-profile-file nix.profile \
      "$@"
    sed -i -E "s#/nix/store/([a-z0-9]{32})-##g" nix.profile
    ${pkgs.flamegraph}/bin/flamegraph.pl nix.profile > flamegraph.svg
  '';

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
    inputs.flat-flake.packages."${system}".flat-flake
    alejandra
    nil
    nix-init
    nix-output-monitor
    nix-prefetch
    nix-prefetch-scripts
    nix-profiling
    nix-search-cli
    nix-store-add
    nixd
    nixfmt-rfc-style
    nixpkgs-fmt
    nodePackages.node2nix
    nurl

    # NodeJS
    (lib.hiPrio nodejs)
    nodePackages.npm

    # Packaging
    dpkg

    # PHP
    phpPackages.composer
    phpWithExtensions

    # Protobuf
    protobuf

    # Python
    (lib.lowPrio python3)
    black
    conda
    # FIXME: broken
    # micromamba
    uv
    virtualenv
    yapf

    # Rust
    rustup

    # Source Control
    subversion

    # Terraform
    terraform

    # TOML
    taplo-cli
    taplo-lsp

    # Others
    azure-cli
    cdrkit
    dhcpcd
    elfx86exts
    flamegraph
    gemini-cli
    gh
    just
    linkzoneAdb
    nur-xddxdd.bin-cpuflags-x86
    oci-cli
    qwen-code
    scc
    tldr
  ];

  home.sessionVariables = {
    AZURE_CONFIG_DIR = "${config.xdg.configHome}/azure";
    OCI_CLI_CONFIG_FILE = "${config.xdg.configHome}/oci/config";
    OCI_CLI_RC_FILE = "${config.xdg.configHome}/oci/oci_cli_rc";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.go = {
    enable = true;
    env = {
      GOBIN = "${config.home.homeDirectory}/.local/bin";
      GOPATH = "${config.xdg.dataHome}/go";
    };
  };

  programs.pyenv.enable = true;
  programs.pylint.enable = true;
}
