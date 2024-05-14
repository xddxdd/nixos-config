{
  pkgs,
  lib,
  LT,
  ...
}:
let
  domains = [
    "lantian.pub"
    "xuyh0120.win"
    "ltn.pw"
  ];
in
{
  lantian.nginxVhosts = builtins.listToAttrs (
    builtins.map (
      { index, value }:
      let
        portStr = builtins.toString (LT.port.GoAutoconfig.Start + index);
      in
      lib.nameValuePair "autoconfig.${value}" {
        locations = {
          "/".proxyPass = "http://127.0.0.1:${portStr}";
        };
        sslCertificate = "${value}_ecc";
        noIndex.enable = true;
      }
    ) (LT.enumerateList domains)
  );

  systemd.services = builtins.listToAttrs (
    builtins.map (
      { index, value }:
      let
        portStr = builtins.toString (LT.port.GoAutoconfig.Start + index);

        format = pkgs.formats.yaml { };
        configFile = format.generate "config.yml" {
          service_addr = "127.0.0.1:${portStr}";
          domain = value;
          imap = {
            server = "witcher.mxrouting.net";
            port = 993;
          };
          smtp = {
            server = "witcher.mxrouting.net";
            port = 465;
          };
        };
      in
      lib.nameValuePair "go-autoconfig-${value}" {
        wantedBy = [ "multi-user.target" ];
        description = "IMAP/SMTP autodiscover server";
        after = [ "network.target" ];
        serviceConfig = LT.serviceHarden // {
          ExecStart = "${pkgs.go-autoconfig}/bin/go-autoconfig -config ${configFile}";
          Restart = "on-failure";
          WorkingDirectory = ''${pkgs.go-autoconfig}/'';
          DynamicUser = true;
        };
      }
    ) (LT.enumerateList domains)
  );
}
