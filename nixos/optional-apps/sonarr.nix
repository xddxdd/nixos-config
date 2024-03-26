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
  imports = [
    ./flaresolverr.nix
    ./qbittorrent.nix
  ];

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

  services.radarr = {
    enable = true;
    user = "lantian";
    group = "users";
    dataDir = "/var/lib/radarr";
  };
  systemd.services.radarr = {
    serviceConfig = LT.serviceHarden // {
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
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
    serviceConfig = LT.serviceHarden // {
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      StateDirectory = "sonarr";
      MemoryDenyWriteExecute = false;
    };
  };

  services.bazarr = {
    enable = true;
    listenPort = LT.port.Bazarr;
    user = "lantian";
    group = "users";
  };
  systemd.services.bazarr = {
    serviceConfig = LT.serviceHarden // {
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      StateDirectory = "bazarr";
      MemoryDenyWriteExecute = false;
    };
  };

  systemd.services.decluttarr = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "radarr.service"
      "sonarr.service"
    ];
    requires = [
      "radarr.service"
      "sonarr.service"
    ];

    environment = {
      # Use environment variables instead of config file
      IS_IN_DOCKER = "1";

      REMOVE_TIMER = "10";
      REMOVE_FAILED = "True";
      REMOVE_STALLED = "True";
      REMOVE_METADATA_MISSING = "True";
      REMOVE_ORPHANS = "True";
      # May break multi season download
      REMOVE_UNMONITORED = "False";
      REMOVE_MISSING_FILES = "True";
      REMOVE_SLOW = "False";
      PERMITTED_ATTEMPTS = "3";
      RADARR_URL = "http://127.0.0.1:${LT.portStr.Radarr}";
      SONARR_URL = "http://127.0.0.1:${LT.portStr.Sonarr}";
    };

    script = ''
      export RADARR_KEY=$(cat /var/lib/radarr/config.xml  | grep -E -o "[0-9a-f]{32}")
      export SONARR_KEY=$(cat /var/lib/sonarr/config.xml  | grep -E -o "[0-9a-f]{32}")
      exec ${pkgs.decluttarr}/bin/decluttarr
    '';

    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "5";

      User = "lantian";
      Group = "users";
    };
  };

  lantian.nginxVhosts = {
    "sonarr.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Sonarr}";
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
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
    "radarr.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Radarr}";
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
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
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
    "bazarr.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Bazarr}";
        };
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "bazarr.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Bazarr}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
