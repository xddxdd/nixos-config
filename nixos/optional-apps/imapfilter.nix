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
  accounts = [
    "gmail"
    "lantian"
    "outlook"
  ];
  email-oauth2-proxy = pkgs.writeShellScriptBin "emailproxy" ''
    exec ${lib.getExe pkgs.nur-xddxdd.email-oauth2-proxy} \
      --no-gui \
      --external-auth \
      --config-file ${inputs.secrets + "/imapfilter/emailproxy.config"} \
      --cache-store /var/lib/email-oauth2-proxy/emailproxy.cache
  '';
  filterJob =
    account:
    netns.bind {
      after = lib.optional (account == "outlook") "email-oauth2-proxy.service";
      requires = lib.optional (account == "outlook") "email-oauth2-proxy.service";
      script = ''
        export PASSWORD_FILE=$CREDENTIALS_DIRECTORY/password
        exec ${lib.getExe pkgs.imapfilter} -t /etc/ssl/certs/ca-certificates.crt -c ${
          inputs.secrets + "/imapfilter/${account}.lua"
        }
      '';
      serviceConfig = LT.serviceHarden // {
        Type = "oneshot";
        LoadCredential = [ "password:${config.sops.secrets."imapfilter-${account}".path}" ];
        User = "imapfilter";
        Group = "imapfilter";
        WorkingDirectory = "/var/cache/imapfilter";
        CacheDirectory = "imapfilter";
        CacheDirectoryMode = "0750";
        # Joins the host-owned network namespace; Lua needs executable mappings.
        PrivateUsers = false;
        MemoryDenyWriteExecute = lib.mkForce false;
        SystemCallFilter = lib.mkForce [ ];
        LimitMEMLOCK = "infinity";
        BindReadOnlyPaths = [ config.sops.secrets."imapfilter-${account}".path ];
      };
      unitConfig = lib.optionalAttrs (account != "outlook") {
        OnFailure = "notify-email@%n.service";
      };
    };
in
{
  lantian.netns.imapfilter.ipSuffix = "93";
  sops.secrets = lib.genAttrs (map (name: "imapfilter-${name}") accounts) (_: {
    sopsFile = inputs.secrets + "/imapfilter/keys.yaml";
    owner = "imapfilter";
    group = "imapfilter";
  });

  environment.systemPackages = [ email-oauth2-proxy ];
  systemd.services = {
    email-oauth2-proxy = netns.bind {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = LT.serviceHarden // {
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
        ExecStart = lib.getExe email-oauth2-proxy;
        User = "email-oauth2-proxy";
        Group = "email-oauth2-proxy";
        WorkingDirectory = "/var/lib/email-oauth2-proxy";
        StateDirectory = "email-oauth2-proxy";
        StateDirectoryMode = "0750";
        PrivateUsers = false;
      };
    };
  }
  // lib.listToAttrs (map (name: lib.nameValuePair "imapfilter-${name}" (filterJob name)) accounts);
  systemd.timers = lib.listToAttrs (
    map (
      name:
      lib.nameValuePair "imapfilter-${name}" {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      }
    ) accounts
  );
  lantian.harden = lib.genAttrs (
    [ "email-oauth2-proxy" ] ++ map (name: "imapfilter-${name}") accounts
  ) (_: true);

  users.users.email-oauth2-proxy = {
    group = "email-oauth2-proxy";
    isSystemUser = true;
  };
  users.groups.email-oauth2-proxy = { };
  users.users.imapfilter = {
    group = "imapfilter";
    isSystemUser = true;
    home = "/var/cache/imapfilter";
    createHome = false;
  };
  users.groups.imapfilter = { };
}
