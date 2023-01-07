{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  # Bypass hotspot restrictions for certain ISPs
  boot.kernel.sysctl."net.ipv4.ip_default_ttl" = 65;
}
