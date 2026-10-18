{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.lantian.harden = lib.mkOption {
    type = lib.types.attrsOf lib.types.bool;
    default = { };
  };

  config = {
    systemd.services = lib.mapAttrs (
      _: v:
      if v then
        {
          serviceConfig = {
            BindReadOnlyPaths = [
              "/etc/machine-id"
              "/etc/resolv.conf"
              "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
              "${config.environment.etc.hosts.source}:/etc/hosts"
              "${pkgs.tzdata}/share/zoneinfo/${config.time.timeZone}:/etc/localtime"
              "${pkgs.tzdata}/share/zoneinfo:/etc/zoneinfo"
            ];
          };
          confinement = {
            enable = true;
            fullUnit = true;
          };
        }
      else
        { }
    ) config.lantian.harden;
  };
}
