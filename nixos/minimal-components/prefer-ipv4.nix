{
  lib,
  LT,
  config,
  ...
}:
{
  options.lantian.prefer-ipv4 = (lib.mkEnableOption "Prefer IPv4 over IPv6") // {
    default = !LT.this.hasTag LT.tags.ipv6-only;
  };

  config = lib.mkIf config.lantian.prefer-ipv4 {
    networking.getaddrinfo = {
      enable = true;
      label = {
        "::1/128" = 0;
        "::/0" = 1;
        "2002::/16" = 2;
        "::/96" = 3;
        "::ffff:0:0/96" = 4;
      };
      precedence = {
        "2002::/16" = 30;
        "::/0" = 40;
        "::/96" = 20;
        "::1/128" = 50;
        "::ffff:0:0/96" = 100;
      };
    };
  };
}
