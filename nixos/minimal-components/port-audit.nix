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

  publicFirewall = config.lantian.firewall.presets.public-firewall;
  # Internal ports are opened alongside the public ones on firewalled
  # hosts (public and internal traffic arrive through the same path) and
  # stay LTnet-only, WAN-blocked by policy, on public hosts.
  allowedPorts =
    publicFirewall.allowedPorts ++ lib.optionals LT.this.firewalled publicFirewall.allowedInternalPorts;
  additionalPorts = lib.optionals (!LT.this.firewalled) publicFirewall.allowedInternalPorts;

  # A port declared both publicly allowed and internal-only is a
  # configuration contradiction; the binary re-checks it as well.
  overlapping = lib.filter (
    a: lib.any (b: rangesOverlap (toRange a) (toRange b)) publicFirewall.allowedPorts
  ) publicFirewall.allowedInternalPorts;

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
  config = {
    assertions = [
      {
        assertion = overlapping == [ ];
        message = "lantian.firewall.presets.public-firewall.allowedInternalPorts must not overlap the public firewall's allowedPorts, overlapping: ${lib.concatStringsSep ", " (map toString overlapping)}";
      }
    ];

    environment.systemPackages = [ portAudit ];
  };
}
