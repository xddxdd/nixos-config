{ pkgs, lib, config, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };

  glauthUsers = import (pkgs.secrets + "/glauth-users.nix");

  netns = LT.netns {
    name = "plausible";
  };
in
{
  imports = [ ../postgresql.nix ];

  age.secrets.plausible-release-cookie = {
    file = pkgs.secrets + "/plausible-release-cookie.age";
    owner = "plausible";
    group = "plausible";
  };
  age.secrets.plausible-secret = {
    file = pkgs.secrets + "/plausible-secret.age";
    owner = "plausible";
    group = "plausible";
  };

  services.clickhouse.enable = true;
  environment.etc = {
    # With changes from https://theorangeone.net/posts/calming-down-clickhouse/
    "clickhouse-server/config.d/custom.xml".source = lib.mkForce ./custom-config.xml;
    "clickhouse-server/users.d/custom.xml".source = lib.mkForce ./custom-users.xml;
  };

  services.plausible = {
    enable = true;
    releaseCookiePath = config.age.secrets.plausible-release-cookie.path;

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

  services.nginx.virtualHosts."stats.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf { } {
      "/" = {
        proxyPass = "http://${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.plausible}:${LT.portStr.Plausible}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true;
  };

  systemd.services = netns.setup // {
    clickhouse = netns.bind {
      serviceConfig = {
        ExecStart = lib.mkForce "${pkgs.clickhouse}/bin/clickhouse-server --config-file=/etc/clickhouse-server/config.xml";
      };
    };
    plausible = netns.bind {
      environment = {
        RELEASE_DISTRIBUTION = "none";
        GEOLITE2_COUNTRY_DB = "/var/lib/GeoIP/GeoLite2-Country.mmdb";
        # LISTEN_IP = LT.this.ltnet.IPv4;
        RELEASE_VM_ARGS = pkgs.writeText "vm.args" ''
          -kernel inet_dist_use_interface "{127,0,0,1}"
        '';
        ERL_EPMD_ADDRESS = "127.0.0.1";

        STORAGE_DIR = lib.mkForce "/run/plausible/elixir_tzdata";
        RELEASE_TMP = lib.mkForce "/run/plausible/tmp";
        HOME = lib.mkForce "/run/plausible";
      };
      serviceConfig = {
        Restart = "always";
        RestartSec = "3";
        DynamicUser = lib.mkForce false;
        User = "plausible";
        Group = "plausible";
        StateDirectory = lib.mkForce "";
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
