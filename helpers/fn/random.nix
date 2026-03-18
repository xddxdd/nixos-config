{
  self,
  lib,
  math,
  ...
}:
rec {
  random = lib.fromHexString (
    builtins.substring 0 15 (
      builtins.convertHash {
        hash = self.narHash;
        toHashFormat = "base16";
      }
    )
  );

  randomSelect = l: builtins.elemAt l (math.mod (math.abs random) (builtins.length l));
}
