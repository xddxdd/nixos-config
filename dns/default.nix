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
