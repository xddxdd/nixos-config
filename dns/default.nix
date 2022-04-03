{ pkgs, lib, hosts, ... }:

let
  dns = import ./core { inherit pkgs lib; };
  common = import ./common { inherit pkgs lib dns hosts; };
in
dns.eval {
  registrars = {
    doh = "DNSOVERHTTPS";
  };
  providers = {
    bind = "BIND";
    cloudflare = "CLOUDFLAREAPI";
    desec = "DESEC";
    henet = "HEDNS";
    ns1 = "NS1";
  };
  domains = builtins.map
    (f: import (./domains + "/${f}") { inherit pkgs lib dns common hosts; })
    (lib.attrNames (builtins.readDir ./domains));
}
