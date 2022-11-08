{ pkgs, lib, ... }:

let
  LT = import ../helpers { inherit pkgs lib; };
  inherit (LT) hosts;

  dns = import ./core { inherit pkgs lib; };
  common = import ./common { inherit pkgs lib dns hosts; };
in
dns.eval {
  registrars = [
    "doh"
  ];
  providers = [
    "bind"
    "cloudflare"
    "desec"
    "henet"
    "ns1"
  ];
  domains = builtins.map
    (f: import (./domains + "/${f}") { inherit pkgs lib dns common hosts; })
    (lib.attrNames (builtins.readDir ./domains));
}
