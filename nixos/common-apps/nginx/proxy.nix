{ LT, ... }:
{
  lantian.nginx-proxy.enable = !(LT.this.hasTag LT.tags.low-ram) || (LT.this.hasTag LT.tags.server);
}
