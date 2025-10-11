{ LT, ... }:
{
  services.iperf3 = {
    enable = !(LT.this.hasTag LT.tags.low-ram);
    bind = LT.this.ltnet.IPv4;
    port = LT.port.IPerf;
  };
}
