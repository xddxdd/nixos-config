{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
lib.mkIf (!(builtins.elem LT.tags.low-ram LT.this.tags)) {
  services.iperf3 = {
    enable = true;
    bind = LT.this.ltnet.IPv4;
    port = LT.port.IPerf;
  };
}
