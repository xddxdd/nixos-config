{
  config,
  pkgs,
  lib,
  ...
}:
key:
builtins.readFile (
  pkgs.runCommandLocal "uuid-${key}" { } ''
    ${pkgs.util-linux}/bin/uuidgen --namespace @oid --sha1 -N "${key}" | tr -d "\n" > $out
  ''
)
