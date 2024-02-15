{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/ccache";
    # Will setup ccache manually on required packages
    packageNames = ["hello"];
  };

  nix.settings = {
    extra-sandbox-paths = [config.programs.ccache.cacheDir];
  };

  security.wrappers.nix-ccache.source = lib.mkForce (pkgs.writeShellScript "nix-ccache.sh" ''
    export CCACHE_DIR=${config.programs.ccache.cacheDir}
    exec ${pkgs.ccache}/bin/ccache "$@"
  '');
}
