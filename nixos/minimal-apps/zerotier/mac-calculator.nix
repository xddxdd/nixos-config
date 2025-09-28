{ lib, ... }:

networkID: nodeID:
let
  getByteAt =
    i:
    let
      networkByte = lib.fromHexString (builtins.substring (14 - 2 * i) 2 networkID);
      networkByteNormalized =
        let
          normalized = builtins.bitOr (builtins.bitAnd networkByte 254) 2;
        in
        if i != 0 then
          networkByte
        else if normalized == 82 then
          50
        else
          normalized;
      nodeByte = lib.fromHexString (builtins.substring (2 * i) 2 "00${nodeID}");
    in
    builtins.bitXor networkByteNormalized nodeByte;

  getHexAt = i: lib.fixedWidthString 2 "0" (lib.toHexString (getByteAt i));
in
lib.concatStringsSep ":" (builtins.genList getHexAt 6)
