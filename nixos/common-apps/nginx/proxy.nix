{ LT, ... }:
{
  lantian.nginx-proxy.enable =
    (LT.this.hasTag LT.tags.server) && (LT.this.hasTag LT.tags.public-facing);
}
