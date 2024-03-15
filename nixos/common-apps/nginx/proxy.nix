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
  lantian.nginx-proxy.enable =
    !(builtins.elem LT.tags.low-ram LT.this.tags) || (builtins.elem LT.tags.server LT.this.tags);
}
