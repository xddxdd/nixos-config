{
  pkgs,
  LT,
  config,
  lib,
  inputs,
  ...
}:
let
  netns = config.lantian.netns.imapfilter;

  email-oauth2-proxy = pkgs.writeShellScriptBin "emailproxy" ''
    exec ${lib.getExe pkgs.nur-xddxdd.email-oauth2-proxy} \
      --no-gui \
      --external-auth \
      --config-file ${inputs.secrets + "/imapfilter/emailproxy.config"} \
      --cache-store /var/lib/email-oauth2-proxy/emailproxy.cache
  '';
in
{
  lantian.netns.imapfilter = {
    ipSuffix = "93";
  };

  age.secrets.imapfilter-gmail = {
    file = inputs.secrets + "/imapfilter/gmail.age";
    owner = "imapfilter";
    group = "imapfilter";
  };

  environment.systemPackages = [ email-oauth2-proxy ];

  systemd.services.email-oauth2-proxy = netns.bind {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = lib.getExe email-oauth2-proxy;

      User = "email-oauth2-proxy";
      Group = "email-oauth2-proxy";

      WorkingDirectory = "/var/lib/email-oauth2-proxy";
      StateDirectory = "email-oauth2-proxy";
      StateDirectoryMode = "0750";
    };
  };

  users.users.email-oauth2-proxy = {
    group = "email-oauth2-proxy";
    isSystemUser = true;
  };
  users.groups.email-oauth2-proxy = { };

  systemd.services.imapfilter-outlook = netns.bind {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.imapfilter} -c ${inputs.secrets + "/imapfilter/outlook.lua"}";

      User = "imapfilter";
      Group = "imapfilter";

      WorkingDirectory = "/var/cache/imapfilter";
      CacheDirectory = "imapfilter";
      CacheDirectoryMode = "0750";

      # Lua requirements
      MemoryDenyWriteExecute = lib.mkForce false;
      SystemCallFilter = lib.mkForce [ ];
      LimitMEMLOCK = "infinity";
    };
    unitConfig = {
      OnFailure = "notify-email@%n.service";
    };
  };

  systemd.timers.imapfilter-outlook = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "4h";
    };
  };

  systemd.services.imapfilter-gmail = netns.bind {
    environment = {
      PASSWORD_FILE = config.age.secrets.imapfilter-gmail.path;
    };
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.imapfilter} -c ${inputs.secrets + "/imapfilter/gmail.lua"}";

      User = "imapfilter";
      Group = "imapfilter";

      WorkingDirectory = "/var/cache/imapfilter";
      CacheDirectory = "imapfilter";
      CacheDirectoryMode = "0750";

      # Lua requirements
      MemoryDenyWriteExecute = lib.mkForce false;
      SystemCallFilter = lib.mkForce [ ];
      LimitMEMLOCK = "infinity";
    };
    unitConfig = {
      OnFailure = "notify-email@%n.service";
    };
  };

  systemd.timers.imapfilter-gmail = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "4h";
    };
  };

  users.users.imapfilter = {
    group = "imapfilter";
    isSystemUser = true;
    home = "/var/cache/imapfilter";
    createHome = false;
  };
  users.groups.imapfilter = { };
}
