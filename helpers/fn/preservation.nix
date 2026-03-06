{ lib, ... }:
rec {
  args = {
    configureParent = true;
  };

  mkFolders = builtins.map (mkFolder' { });
  mkFolder' =
    a: f:
    let
      directory = if builtins.isAttrs f then f.directory else f;
      attrs =
        (if builtins.isAttrs f then f else { directory = f; })
        // (lib.optionalAttrs (lib.hasPrefix "/etc/" directory) {
          how = "symlink";
          createLinkTarget = true;
        });
    in
    attrs // args // a;

  mkFiles = builtins.map (mkFile' { });
  mkFile' =
    a: f:
    let
      file = if builtins.isAttrs f then f.file else f;
      attrs =
        (if builtins.isAttrs f then f else { file = f; })
        // (lib.optionalAttrs (lib.hasPrefix "/etc/" file) {
          how = "symlink";
          createLinkTarget = true;
        });
    in
    attrs // args // a;
}
