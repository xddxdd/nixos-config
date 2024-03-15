{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
lib.mkIf (!(LT.this.hasTag LT.tags.low-ram)) {
  services.iperf3 = {
    enable = true;
    bind = LT.this.ltnet.IPv4;
    port = LT.port.IPerf;
  };
}
