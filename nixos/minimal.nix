{ ... }:
{
  imports =
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
    in
    (ls ./minimal-apps)
    ++ (ls ./minimal-components)
    ++ (ls ./minimal-modules)
    ++ (ls ./minimal-policies);
}
