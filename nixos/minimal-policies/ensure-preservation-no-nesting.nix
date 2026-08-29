{
  lib,
  config,
  ...
}:
let
  directories =
    let
      raw = config.lantian.preservation.directories;
    in
    map (d: if builtins.isAttrs d then d.directory else d) raw;

  normalized = map (d: "${lib.removeSuffix "/" d}/") directories;

  isSubdirOf = sub: parent: lib.hasPrefix parent sub && sub != parent;
in
{
  assertions =
    let
      pairs = lib.concatMap (a: map (b: { inherit a b; }) (lib.filter (x: x != a) normalized)) normalized;
      nested = lib.filter ({ a, b }: isSubdirOf a b) pairs;
    in
    map (
      { a, b }:
      {
        assertion = false;
        message = "lantian.preservation: \"${lib.removeSuffix "/" a}\" is a subdirectory of \"${lib.removeSuffix "/" b}\", nested preservation is redundant";
      }
    ) nested;
}
