{
  pkgs,
  lib,
  LT,
  ...
}:
let
  inherit (pkgs.nur-xddxdd) flapalerted;
in
{
  systemd.services.flapalerted = {
    description = "FlapAlerted";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    requires = [ "network.target" ];

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      RuntimeDirectory = "flapalerted";
      UMask = "007";

      Group = "bird";
      User = "bird";

      ExecStart = builtins.concatStringsSep " " [
        "${lib.getExe flapalerted}"
        "--asn 4242422547"
        "--bgpListenAddress [${LT.this.ltnet.IPv6}]:${LT.portStr.FlapAlerted.BGP}"
        "--httpAPIListenAddress /run/flapalerted/flapalerted.sock"
        "-routeChangeCounter 120"
        "-overThresholdTarget 5"
        "-underThresholdTarget 30"
      ];
    };
  };

  users.groups.bird.members = [ "nginx" ];

  lantian.nginxVhosts."flapalerted.lantian.pub" = {
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/flapalerted/flapalerted.sock";
      };
    };

    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };
}
