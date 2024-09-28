{ LT, ... }:
{
  services.iperf3 = {
    enable = true;
    bind = LT.this.ltnet.IPv4;
  };
}
