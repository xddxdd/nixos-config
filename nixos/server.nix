{ ... }:
{
  imports =
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
    in
    (ls ./minimal-apps)
    ++ (ls ./common-apps)
    ++ (ls ./server-apps)
    ++ (ls ./minimal-components)
    ++ (ls ./server-components);
}
