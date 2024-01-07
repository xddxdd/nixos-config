{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  lantian.nginxVhosts."rsshub.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/rsshub/rsshub.sock";
      };
    };

    sslCertificate = "xuyh0120.win_ecc";
    noIndex.enable = true;
    accessibleBy = "private";
  };

  systemd.services.rsshub = {
    description = "RSSHub";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    requires = ["network-online.target"];

    environment = {
      CACHE_CONTENT_EXPIRE = "600";
      CHROMIUM_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
      HOME = "/var/cache/rsshub";
      LISTEN_INADDR_ANY = "0";
      PORT = "0";
      SOCKET = "/run/rsshub/rsshub.sock";
    };

    path = with pkgs; [gitMinimal];

    serviceConfig =
      LT.serviceHarden
      // {
        EnvironmentFile = config.age.secrets.waline-env.path;
        ExecStartPre = "${pkgs.yarn}/bin/yarn add rsshub";
        ExecStart = "${pkgs.nodejs}/bin/node node_modules/rsshub/lib/index.js";

        Restart = "always";
        RestartSec = "3";

        CacheDirectory = "rsshub";
        WorkingDirectory = "/var/cache/rsshub";
        RuntimeDirectory = "rsshub";
        RuntimeDirectoryMode = lib.mkForce "0775";
        UMask = "002";

        User = "rsshub";
        Group = "rsshub";
        MemoryDenyWriteExecute = lib.mkForce false;
      };
  };

  users.users.rsshub = {
    group = "rsshub";
    isSystemUser = true;
  };
  users.groups.rsshub.members = ["nginx"];
}
