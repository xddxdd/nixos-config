{ LT, pkgs, ... }:
{
  systemd.services.rsshub = {
    description = "RSSHub";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      PORT = LT.portStr.RSSHub;
      LISTEN_INADDR_ANY = "0";
      CACHE_CONTENT_EXPIRE = "600";
    };

    serviceConfig = LT.serviceHarden // {
      User = "rsshub";
      Group = "rsshub";

      ExecStart = "${pkgs.rsshub}/bin/rsshub";

      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];

      MemoryDenyWriteExecute = false;
      Restart = "always";
      RestartSec = 5;
    };
  };

  users.users.rsshub = {
    group = "rsshub";
    isSystemUser = true;
  };
  users.groups.rsshub = { };

  lantian.nginxVhosts."rsshub.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.RSSHub}";
      };
    };

    sslCertificate = "lets-encrypt-xuyh0120.win";
    noIndex.enable = true;
    accessibleBy = "private";
  };
}
