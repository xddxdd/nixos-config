_: dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir))
