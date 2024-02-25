{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  # Bypass hotspot restrictions for certain ISPs
  boot.kernel.sysctl = {
    "net.ipv4.ip_default_ttl" = 65;
    "net.ipv6.conf.all.hop_limit" = 65;
    "net.ipv6.conf.default.hop_limit" = 65;
    "net.ipv6.conf.*.hop_limit" = 65;
  };
}
