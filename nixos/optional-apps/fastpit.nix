{
  pkgs,
  lib,
  LT,
  ...
}:
let
  fastpit = pkgs.callPackage ../../pkgs/fastpit { };
in
{
  systemd.services.fastpit = {
    description = "fastpit";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${lib.getExe fastpit} --socket /run/fastpit/fastpit.sock --seed 2547 --asset-dir ${fastpit}/share/fastpit/assets";
      Restart = "always";
      RestartSec = "3";

      RuntimeDirectory = "fastpit";
      RuntimeDirectoryMode = "0770";
      WorkingDirectory = "/run/fastpit";
      User = "fastpit";
      Group = "fastpit";
    };
  };

  lantian.nginxVhosts."posts.lantian.pub" = {
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/fastpit/fastpit.sock";
      };
    };
    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };

  users.users.fastpit = {
    group = "fastpit";
    isSystemUser = true;
  };
  users.groups.fastpit.members = [ "nginx" ];
}
