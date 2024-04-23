{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  services.k3s = {
    enable = true;
    role = "server";
  };
}
