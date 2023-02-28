{
  pkgs,
  lib,
  LT,
  inputs,
  ...
} @ args: let
  inherit (LT) hosts;

  dns = import ./core {inherit pkgs lib;};
  common = import ./common {inherit pkgs lib dns hosts;};
in
  dns.eval {
    registrars = [
      "doh"
    ];
    providers = [
      "bind"
      "cloudflare"
      "desec"
      "gcore"
      "henet"
    ];
    domains =
      builtins.map
      (f: import (./domains + "/${f}") {inherit pkgs lib dns common hosts;})
      (lib.attrNames (builtins.readDir ./domains));
  }
