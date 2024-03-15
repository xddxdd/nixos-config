{
  pkgs,
  lib,
  LT,
  config,
  options,
  utils,
  inputs,
  ...
}@args:
{
  options.lantian.prefer-ipv4 = (lib.mkEnableOption "Prefer IPv4 over IPv6") // {
    default = true;
  };

  config = lib.mkIf config.lantian.prefer-ipv4 {
    environment.etc."gai.conf".text = ''
      label ::1/128       0
      label ::/0          1
      label 2002::/16     2
      label ::/96         3
      label ::ffff:0:0/96 4
      precedence ::ffff:0:0/96 100
      precedence ::1/128       50
      precedence ::/0          40
      precedence 2002::/16     30
      precedence ::/96         20
    '';
  };
}
