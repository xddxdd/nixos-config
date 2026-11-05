{
  config,
  lib,
  LT,
  pkgs,
  ...
}:
# Interim package roll-out: install a host-specific wrapper so `port-audit`
# can be invoked bare (allowed ports, LTnet-only ports, ephemeral expectation
# and reserved CIDRs are injected from eval-time config). The scheduled timer
# will be wired on top of this wrapper in a later step.
let
  # Normalize an allowedPort/additionalPort element (`22` or `"20000-23999"`)
  # into an inclusive numeric range.
  toRange =
    p:
    let
      parts = lib.splitString "-" (toString p);
    in
    {
      lo = lib.toInt (lib.head parts);
      hi = lib.toInt (lib.last parts);
    };

  rangesOverlap = x: y: x.lo <= y.hi && y.lo <= x.hi;

  additionalPorts = config.lantian.port-audit.additionalPorts;
  allowedPorts = config.lantian.firewall.presets.public-firewall.allowedPorts;

  overlapping = lib.filter (
    a: lib.any (b: rangesOverlap (toRange a) (toRange b)) allowedPorts
  ) additionalPorts;

  portAudit = pkgs.writeShellScriptBin "port-audit" ''
    export PORT_AUDIT_ALLOWED=${lib.concatStringsSep "," (map toString allowedPorts)}
    export PORT_AUDIT_ADDITIONAL=${lib.concatStringsSep "," (map toString additionalPorts)}
    export PORT_AUDIT_EPHEMERAL=${LT.portStr.Ephemeral.Start}-${LT.portStr.Ephemeral.End}
    export PORT_AUDIT_RESERVED_V4=${lib.concatStringsSep "," LT.constants.reserved.IPv4}
    export PORT_AUDIT_RESERVED_V6=${lib.concatStringsSep "," LT.constants.reserved.IPv6}
    exec ${lib.getExe pkgs.port-audit}
  '';
in
{
  options.lantian.port-audit.additionalPorts = lib.mkOption {
    type = lib.types.listOf (lib.types.either lib.types.int lib.types.str);
    default = [ ];
    description = ''
      Listening ports that are expected within LTnet but must never be
      reachable from WAN. Listeners on these ports are exempt from the
      audit's violation report; the assertion below rejects any overlap with
      the public firewall's allowedPorts.
    '';
  };

  config = {
    assertions = [
      {
        assertion = overlapping == [ ];
        message = "lantian.port-audit.additionalPorts must not overlap lantian.firewall.presets.public-firewall.allowedPorts, overlapping: ${lib.concatStringsSep ", " (map toString overlapping)}";
      }
    ];

    environment.systemPackages = [ portAudit ];
  };
}
