{
  lib,
  LT,
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
in
rec {
  ipv4Set = mkIpSet "ipv4_addr";
  ipv6Set = mkIpSet "ipv6_addr";

  interfaceSet = name: prefixes: ''
    set INTERFACE_${name} {
      type ifname
      flags constant, interval
      elements = { ${lib.concatMapStringsSep ", " (v: v + "*") prefixes} }
    }
  '';

  interfaceSets = lib.concatMapAttrsStringSep "\n" (
    k: v: interfaceSet k v
  ) LT.constants.interfacePrefixes;
}
