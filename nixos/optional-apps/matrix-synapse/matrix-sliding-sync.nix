{
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  imports = [ ../postgresql.nix ];

  age.secrets.matrix-sliding-sync-env.file = inputs.secrets + "/matrix-sliding-sync-env.age";

  services.matrix-sliding-sync = {
    enable = true;
    createDatabase = true;
    environmentFile = config.age.secrets.matrix-sliding-sync-env.path;
    settings = {
      SYNCV3_BINDADDR = "127.0.0.1:0";
      SYNCV3_UNIX_SOCKET = "/run/matrix-sliding-sync/listen.socket";
      SYNCV3_SERVER = "https://matrix.lantian.pub";
    };
  };

  systemd.services.matrix-sliding-sync.serviceConfig = LT.serviceHarden // {
    DynamicUser = lib.mkForce false;
    User = "matrix-sliding-sync";
    Group = "matrix-sliding-sync";
    RuntimeDirectory = "matrix-sliding-sync";
    StateDirectory = lib.mkForce [ ];
    WorkingDirectory = lib.mkForce "/run/matrix-sliding-sync";
    UMask = "007";
  };

  users.users.matrix-sliding-sync = {
    group = "matrix-sliding-sync";
    isSystemUser = true;
  };
  users.groups.matrix-sliding-sync.members = [ "nginx" ];
}
