{ ... }:
{
  imports =
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
    in
    (ls ./minimal-components)
    ++ (ls ./pve-components)
    ++ (ls ./minimal-modules)
    ++ (ls ./minimal-policies);
}
