{
  lib,
  ...
}:
let
  mkIpSet = family: name: value: ''
    set ${name} {
      type ${family}
      flags constant, interval
      elements = { ${builtins.concatStringsSep ", " value} }
    }
  '';

  mkIfnameSet = name: prefixes: ''
    set ${name} {
      type ifname
      flags constant, interval
      elements = { ${lib.concatMapStringsSep ", " (v: v + "*") prefixes} }
    }
  '';
in
rec {
  ipv4Set = mkIpSet "ipv4_addr";
  ipv6Set = mkIpSet "ipv6_addr";
  ifnameSet = mkIfnameSet;
}
