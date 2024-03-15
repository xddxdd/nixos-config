{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
}@args:
{
  imports =
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
    in
    [
      ./common
      ./core

      ./domains/56631131.xyz.nix
    ]
    ++ ls ./domains;

  registrars = [
    "doh"
    "porkbun"
  ];
  providers = [
    "bind"
    "cloudflare"
    "desec"
    "gcore"
    "henet"
  ];
}
