{ LT, config, ... }:
{
  services.iodine.server = {
    enable = true;
    ip = "203.0.113.1/24";
    domain = "dt.56631131.xyz";
    extraConfig = "-l ${LT.this.ltnet.IPv4} -p ${LT.portStr.Iodine} -c -n ${LT.this.public.IPv4}";
    passwordFile = config.age.secrets.default-pw.path;
  };

  systemd.services.iodined.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };
}
