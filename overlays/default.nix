args:

builtins.map
  (f: (import (./. + "/${f}") args))
  (builtins.filter
    (f: f != "default.nix")
    (builtins.attrNames (builtins.readDir ./.)))
