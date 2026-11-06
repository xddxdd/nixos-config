{
  config,
  lib,
  LT,
  pkgs,
  ...
}:
# Interim package roll-out: install a host-specific wrapper so `port-audit`
# can be invoked bare (allowed ports, LTnet-only ports, known-violation ports,
# ephemeral expectation and reserved CIDRs are injected from eval-time config).
# Client hosts skip the listener audit; the scheduled timer will be wired on
# top of this wrapper in a later step.
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

  knownViolations = config.lantian.port-audit.knownViolations;
  # A known violation that is also allowlisted is a contradiction: the
  # firewall accepts the port, so the exception would hide a real gap
  # instead of exempting a listener that is deliberately unreachable.
  allowlisted = publicFirewall.allowedPorts ++ publicFirewall.allowedInternalPorts;
  knownViolationOverlap = lib.filter (
    k: lib.any (a: rangesOverlap (toRange k) (toRange a)) allowlisted
  ) knownViolations;

  # Desktop clients run applications that bind wildcard ports for LAN-only
  # services (Steam Remote Play, FluidSynth's shell server, libvirt's DHCP
  # dnsmasq, ...), so the listener audit only checks non-client hosts, where
  # every public listener must be deliberate.
  auditListeners = !LT.this.hasTag LT.tags.client;

  portAudit = pkgs.writeShellScriptBin "port-audit" (
    if auditListeners then
      ''
        export PORT_AUDIT_ALLOWED=${lib.concatStringsSep "," (map toString allowedPorts)}
        export PORT_AUDIT_ADDITIONAL=${lib.concatStringsSep "," (map toString additionalPorts)}
        export PORT_AUDIT_KNOWN_VIOLATIONS=${lib.concatStringsSep "," (map toString knownViolations)}
        export PORT_AUDIT_EPHEMERAL=${LT.portStr.Ephemeral.Start}-${LT.portStr.Ephemeral.End}
        export PORT_AUDIT_RESERVED_V4=${lib.concatStringsSep "," LT.constants.reserved.IPv4}
        export PORT_AUDIT_RESERVED_V6=${lib.concatStringsSep "," LT.constants.reserved.IPv6}
        exec ${lib.getExe pkgs.port-audit}
      ''
    else
      ''
        echo "port-audit: client host: listener audit skipped"
      ''
  );
in
{
  options.lantian.port-audit.knownViolations = lib.mkOption {
    type = lib.types.listOf (lib.types.either lib.types.int lib.types.str);
    default = [ ];
    description = ''
      Ports that are known to be bound on public or wildcard addresses
      while the firewall keeps them closed, such as a daemon's built-in
      status listener that only serves internal clients. The audit skips
      them rather than reporting a violation. They must not overlap
      allowedPorts or allowedInternalPorts, since an allowlisted port is
      reachable under firewall policy and needs no exception.
    '';
  };

  config = {
    assertions = [
      {
        assertion = overlapping == [ ];
        message = "lantian.firewall.presets.public-firewall.allowedInternalPorts must not overlap the public firewall's allowedPorts, overlapping: ${lib.concatStringsSep ", " (map toString overlapping)}";
      }
      {
        assertion = knownViolationOverlap == [ ];
        message = "lantian.port-audit.knownViolations must not overlap the public firewall's allowedPorts or allowedInternalPorts, overlapping: ${lib.concatStringsSep ", " (map toString knownViolationOverlap)}";
      }
    ];

    environment.systemPackages = [ portAudit ];
  };
}
