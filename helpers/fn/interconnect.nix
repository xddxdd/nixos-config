{ hosts, this, ... }:
rec {
  interconnectIPv4For =
    host:
    if
      this.interconnect.name != null
      && this.interconnect.IPv4 != null
      && hosts."${host}".interconnect.name == this.interconnect.name
      && hosts."${host}".interconnect.IPv4 != null
    then
      hosts."${host}".interconnect.IPv4
    else
      null;

  publicIPv4For =
    host:
    if interconnectIPv4For host != null then interconnectIPv4For host else hosts."${host}".public.IPv4;

  interconnectIPv6For =
    host:
    if
      this.interconnect.name != null
      && this.interconnect.IPv6 != null
      && hosts."${host}".interconnect.name == this.interconnect.name
      && hosts."${host}".interconnect.IPv6 != null
    then
      hosts."${host}".interconnect.IPv6
    else
      null;

  publicIPv6For =
    host:
    if interconnectIPv6For host != null then interconnectIPv6For host else hosts."${host}".public.IPv6;
}
