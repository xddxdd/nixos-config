{ LT, ... }:
{
  # FIXME: temporarily disabled
  lantian.nginx-proxy.enable = false;
  # lantian.nginx-proxy.enable =
  #   (LT.this.hasTag LT.tags.server) && (LT.this.hasTag LT.tags.public-facing);
}
