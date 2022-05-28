{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };

  glauthUsers = import (pkgs.secrets + "/glauth-users.nix");

  netns = LT.netns {
    name = "plausible";
  };
in
{
  imports = [ ./postgresql.nix ];

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
      baseUrl = "https://stats.lantian.pub";
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

  services.nginx.virtualHosts."stats.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf { } {
      "/" = {
        proxyPass = "http://${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.plausible}:13800";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true;
  };

  systemd.services = netns.setup // {
    clickhouse = netns.bind { };
    plausible = netns.bind {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      environment = {
        RELEASE_DISTRIBUTION = "none";
      };
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "plausible";
        Group = "plausible";
      };
    };
  };

  users.users.plausible = {
    group = "plausible";
    isSystemUser = true;
  };
  users.groups.plausible = { };
}
