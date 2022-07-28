{ lib, roles, ... }:

n: v: lib.recursiveUpdate
{
  hostname = "${n}.lantian.pub";
  ptrPrefix = "";
  role = roles.server;
  sshPort = 2222;
  system = "x86_64-linux";
  openvz = false;

  ssh = {
    ed25519 = "";
    rsa = "";
  };
  tinc = {
    ed25519 = "";
    rsa = "";
  };
  syncthing = "";
  public = {
    IPv4 = "";
    IPv6 = "";
    IPv6Alt = "";
    IPv6Subnet = "";
  };
  ltnet = rec {
    alone = false;
    IPv4 = "${IPv4Prefix}.1";
    IPv4Prefix = "172.18.${builtins.toString v.index}";
    IPv6 = "${IPv6Prefix}::1";
    IPv6Prefix = "fdbc:f9dc:67ad:${builtins.toString v.index}";
  };
  dn42 = {
    IPv4 = "";
    IPv6 = "fdbc:f9dc:67ad:${builtins.toString v.index}::1";
  };
  neonetwork = rec {
    IPv4 = "10.127.10.${builtins.toString v.index}";
    IPv6 = "fd10:127:10:${builtins.toString v.index}::1";
  };
  yggdrasil = {
    IPv4 = "";
    IPv6 = "";
  };
}
  v
