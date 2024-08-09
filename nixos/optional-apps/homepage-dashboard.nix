{
  LT,
  config,
  lib,
  inputs,
  ...
}:
let
  calendarIntegrations = [
    {
      type = "sonarr";
      service_group = "影音";
      service_name = "Sonarr";
    }
    {
      type = "radarr";
      service_group = "影音";
      service_name = "Radarr";
    }
    {
      type = "ical";
      url = "{{HOMEPAGE_VAR_ICAL_LINK}}";
      name = "日程";
    }
  ];
in
{
  age.secrets.homepage-dashboard-env = {
    file = inputs.secrets + "/homepage-dashboard-env.age";
    owner = "homepage-dashboard";
    group = "homepage-dashboard";
  };

  services.homepage-dashboard = {
    enable = true;
    listenPort = LT.port.HomepageDashboard;
    environmentFile = config.age.secrets.homepage-dashboard-env.path;

    settings = {
      title = "Lan Tian @ Dashboard";
      headerStyle = "clean";
      language = "zh-CN";
      target = "_blank";
      disableCollapse = true;
      hideVersion = true;
      # Ignore errors for network instability
      hideErrors = true;
    };

    customCSS = ''
      #footer { display: none !important; }
    '';

    services = [
      {
        "今日" = [
          {
            "日历" = {
              widget = {
                type = "calendar";
                firstDayInWeek = "sunday";
                view = "monthly";
                maxEvents = 10;
                showTime = true;
                integrations = calendarIntegrations;
              };
            };
          }
          {
            "日程" = {
              widget = {
                type = "calendar";
                firstDayInWeek = "sunday";
                view = "agenda";
                maxEvents = 10;
                showTime = true;
                previousDays = 1;
                integrations = calendarIntegrations;
              };
            };
          }
        ];
      }
      {
        "影音" = [
          {
            "Jellyfin" = {
              icon = "jellyfin.svg";
              href = "https://jellyfin.xuyh0120.win";
              widget = {
                type = "jellyfin";
                url = "https://jellyfin.xuyh0120.win";
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
              };
            };
          }
          {
            "Sonarr" = {
              icon = "sonarr.svg";
              href = "https://sonarr.lt-home-vm.xuyh0120.win";
              widget = {
                type = "sonarr";
                url = "https://sonarr.lt-home-vm.xuyh0120.win";
                key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
              };
            };
          }
          {
            "Radarr" = {
              icon = "radarr.svg";
              href = "https://radarr.lt-home-vm.xuyh0120.win";
              widget = {
                type = "radarr";
                url = "https://radarr.lt-home-vm.xuyh0120.win";
                key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
              };
            };
          }
          {
            "Prowlarr" = {
              icon = "prowlarr.svg";
              href = "https://prowlarr.lt-home-vm.xuyh0120.win";
              widget = {
                type = "prowlarr";
                url = "https://prowlarr.lt-home-vm.xuyh0120.win";
                key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
              };
            };
          }
          {
            "qBitTorrent" = {
              icon = "qbittorrent.svg";
              href = "https://qbittorrent.lt-home-vm.xuyh0120.win";
              widget = {
                type = "qbittorrent";
                url = "https://qbittorrent.lt-home-vm.xuyh0120.win";
                username = "nobody";
                password = "";
              };
            };
          }
          {
            "Transmission" = {
              icon = "transmission.svg";
              href = "https://transmission.lt-home-vm.xuyh0120.win";
              widget = {
                type = "transmission";
                url = "http://lt-home-vm.xuyh0120.win:9091";
                username = "nobody";
                password = "";
              };
            };
          }
        ];
      }
    ];

    widgets = [
      {
        greeting = {
          text_size = "xl";
          text = config.services.homepage-dashboard.settings.title;
        };
      }
      {
        datetime = {
          text_size = "xl";
          format = {
            dateStyle = "short";
            timeStyle = "short";
            hour12 = true;
          };
        };
      }
      {
        openmeteo = {
          latitude = LT.this.city.lat;
          longitude = LT.this.city.lng;
          timezone = config.time.timeZone;
          units = "metric";
          cache = 5;
          format.maximumFractionDigits = 1;
        };
      }
    ];
  };

  systemd.services.homepage-dashboard.serviceConfig = LT.serviceHarden // {
    DynamicUser = lib.mkForce false;
    User = "homepage-dashboard";
    Group = "homepage-dashboard";
    MemoryDenyWriteExecute = lib.mkForce false;
    SystemCallFilter = lib.mkForce [ ];
  };

  users.users.homepage-dashboard = {
    group = "homepage-dashboard";
    isSystemUser = true;
  };
  users.groups.homepage-dashboard = { };

  lantian.nginxVhosts = {
    "homepage.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.HomepageDashboard}";
        };
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
      accessibleBy = "private";
    };
    "homepage.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.HomepageDashboard}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
