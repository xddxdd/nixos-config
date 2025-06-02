_: rec {
  args = {
    configureParent = true;
  };

  mkFolder = mkFolder' { };
  mkFolder' =
    a: f:
    let
      attrs = if builtins.isAttrs f then f else { directory = f; };
    in
    attrs // args // a;

  mkFile = mkFile' { };
  mkFile' =
    a: f:
    let
      attrs = if builtins.isAttrs f then f else { file = f; };
    in
    attrs // args // a;
}
