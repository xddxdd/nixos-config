{inputs, ...}: final: prev: {
  composer2nix = final.callPackage (inputs.composer2nix) {};
}
