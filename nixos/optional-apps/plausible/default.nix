{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
let
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");

  netns = config.lantian.netns.plausible;
in
{
  imports = [ ../postgresql.nix ];

  age.secrets.plausible-secret = {
    file = inputs.secrets + "/plausible-secret.age";
    owner = "plausible";
    group = "plausible";
  };

  lantian.netns.plausible = {
    ipSuffix = "138";
  };

  services.clickhouse.enable = true;
  environment.etc = {
    # With changes from https://theorangeone.net/posts/calming-down-clickhouse/
    "clickhouse-server/config.d/custom.xml".source = lib.mkForce ./custom-config.xml;
    "clickhouse-server/users.d/custom.xml".source = lib.mkForce ./custom-users.xml;
  };

  services.epmd.enable = lib.mkForce false;

  services.plausible = {
    enable = true;

    mail = {
      email = config.programs.msmtp.accounts.default.from;
      smtp.user = config.programs.msmtp.accounts.default.user;
      smtp.hostPort = config.programs.msmtp.accounts.default.port;
      smtp.hostAddr = config.programs.msmtp.accounts.default.host;
      smtp.enableSSL = config.programs.msmtp.accounts.default.tls;
      smtp.passwordFile = config.age.secrets.smtp-pass.path;
    };

    server = {
      port = LT.port.Plausible;
      baseUrl = "https://stats.xuyh0120.win";
      disableRegistration = true;
      secretKeybaseFile = config.age.secrets.plausible-secret.path;
    };

    adminUser = {
      activate = true;
      name = "lantian";
      email = glauthUsers.lantian.mail;
      passwordFile = config.age.secrets.default-pw.path;
    };
  };

  lantian.nginxVhosts."stats.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://${config.lantian.netns.plausible.ipv4}:${LT.portStr.Plausible}";
      };
    };

    sslCertificate = "xuyh0120.win_ecc";
  };

  systemd.services = {
    clickhouse = netns.bind {
      serviceConfig = LT.serviceHarden // {
        MemoryDenyWriteExecute = lib.mkForce false;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];
        SystemCallFilter = lib.mkForce [ ];
      };
    };
    plausible = netns.bind {
      environment = {
        RELEASE_DISTRIBUTION = "none";
        LISTEN_IP = lib.mkForce "0.0.0.0";
        RELEASE_VM_ARGS = pkgs.writeText "vm.args" ''
          -kernel inet_dist_use_interface "{127,0,0,1}"
        '';
        ERL_EPMD_ADDRESS = "127.0.0.1";

        GEOLITE2_COUNTRY_DB = "/var/lib/GeoIP/GeoLite2-Country.mmdb";
        GEONAMES_SOURCE_FILE = "/var/lib/plausible/geonames.csv";
        IP_GEOLOCATION_DB = "/var/lib/GeoIP/GeoLite2-City.mmdb";

        STORAGE_DIR = lib.mkForce "/run/plausible/elixir_tzdata";
        RELEASE_TMP = lib.mkForce "/run/plausible/tmp";
        HOME = lib.mkForce "/run/plausible";
      };
      serviceConfig = LT.serviceHarden // {
        Restart = "always";
        RestartSec = "3";
        DynamicUser = lib.mkForce false;
        User = "plausible";
        Group = "plausible";
        StateDirectory = lib.mkForce "plausible";
        RuntimeDirectory = "plausible";
        WorkingDirectory = lib.mkForce "/run/plausible";
      };
    };
  };

  users.users.plausible = {
    group = "plausible";
    isSystemUser = true;
  };
  users.groups.plausible = { };
}
