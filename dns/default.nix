{ pkgs, hosts, ... }:

let
  dns = import ./core { inherit pkgs; };
  common = import ./common { inherit pkgs dns hosts; };
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
  };
  domains = builtins.map
    (f: import (./domains + "/${f}") { inherit pkgs dns common hosts; })
    (pkgs.lib.attrNames (builtins.readDir ./domains));
}
