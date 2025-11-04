{
  lib,
  LT,
  config,
  ...
}:
let
  cfg = config.services.lemmy;
in
{
  imports = [
    ./pict-rs.nix
    ./postgresql.nix
  ];

  services.lemmy = {
    enable = true;
    database.uri = "postgres:///lemmy?host=/run/postgresql&user=lemmy";
    ui.port = LT.port.Lemmy.UI;

    settings = {
      hostname = "lemmy.lantian.pub";
      port = LT.port.Lemmy.API;
      pictrs.image_mode = "ProxyAllImages";
    };
  };

  services.postgresql = {
    ensureDatabases = [ "lemmy" ];
    ensureUsers = [
      {
        name = "lemmy";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.lemmy-ui.enable = lib.mkForce false;

  lantian.nginxVhosts."lemmy.lantian.pub" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString cfg.settings.port}";
      proxyWebsockets = true;
    };

    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };

  systemd.services.lemmy = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];

    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "3";
      DynamicUser = lib.mkForce false;
      User = "lemmy";
      Group = "lemmy";
    };
  };

  systemd.services.lemmy-ui.serviceConfig = LT.serviceHarden // {
    Restart = "always";
    RestartSec = "3";
    DynamicUser = lib.mkForce false;
    MemoryDenyWriteExecute = false;
    User = "lemmy";
    Group = "lemmy";
  };

  users.users.lemmy = {
    group = "lemmy";
    isSystemUser = true;
  };
  users.groups.lemmy = { };
}
