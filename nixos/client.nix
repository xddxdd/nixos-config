{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = let
    ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
  in
    []
    ++ (ls ./minimal-apps)
    ++ (ls ./common-apps)
    ++ (ls ./client-apps)
    ++ (ls ./minimal-components)
    ++ (ls ./client-components);
}
