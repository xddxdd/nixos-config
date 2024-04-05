{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  services.prowlarr.enable = true;
  systemd.services.prowlarr = {
    serviceConfig = LT.serviceHarden // {
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      MemoryDenyWriteExecute = false;
      DynamicUser = lib.mkForce false;
      User = "lantian";
      Group = "users";
    };
  };
  lantian.nginxVhosts = {
    "prowlarr.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Prowlarr}";
        };
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "prowlarr.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Prowlarr}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
