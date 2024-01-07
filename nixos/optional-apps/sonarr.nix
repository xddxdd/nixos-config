{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [
    ./qbittorrent.nix
  ];

  services.prowlarr.enable = true;
  systemd.services.prowlarr = {
    serviceConfig =
      LT.serviceHarden
      // {
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
        MemoryDenyWriteExecute = false;
        DynamicUser = lib.mkForce false;
        User = "lantian";
        Group = "users";
      };
  };

  services.radarr = {
    enable = true;
    user = "lantian";
    group = "users";
    dataDir = "/var/lib/radarr";
  };
  systemd.services.radarr = {
    serviceConfig =
      LT.serviceHarden
      // {
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
        StateDirectory = "radarr";
        MemoryDenyWriteExecute = false;
      };
  };

  services.sonarr = {
    enable = true;
    user = "lantian";
    group = "users";
    dataDir = "/var/lib/sonarr";
  };
  systemd.services.sonarr = {
    serviceConfig =
      LT.serviceHarden
      // {
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
        StateDirectory = "sonarr";
        MemoryDenyWriteExecute = false;
      };
  };

  systemd.services.flaresolverr = {
    description = "FlareSolverr";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    wants = ["network.target"];
    path = with pkgs; [
      xorg.xorgserver
    ];
    environment = {
      HOME = "/run/flaresolverr";
      HOST = "127.0.0.1";
      PORT = LT.portStr.FlareSolverr;
      LOG_LEVEL = "warn";
    };
    serviceConfig =
      LT.serviceHarden
      // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${pkgs.flaresolverr}/bin/flaresolverr";
        RuntimeDirectory = "flaresolverr";
        WorkingDirectory = "/run/flaresolverr";

        MemoryDenyWriteExecute = false;
        SystemCallFilter = lib.mkForce [];
      };
  };

  lantian.nginxVhosts = {
    "sonarr.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Sonarr}";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "sonarr.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Sonarr}";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
    "radarr.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Radarr}";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "radarr.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Radarr}";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
    "prowlarr.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Prowlarr}";
          extraConfig = LT.nginx.locationProxyConf;
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
          extraConfig = LT.nginx.locationProxyConf;
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
