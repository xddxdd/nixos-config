_: {
  # Emulate Windows
  boot.kernel.sysctl = {
    "net.ipv4.ip_default_ttl" = 128;
    "net.ipv6.conf.all.hop_limit" = 128;
    "net.ipv6.conf.default.hop_limit" = 128;
    "net.ipv6.conf.*.hop_limit" = 128;
  };
}
