{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  netns = config.lantian.netns.netease;

  inherit (pkgs) netease-cloud-music;
in
{
  environment.systemPackages = [ netease-cloud-music ];

  environment.etc."netns/netease/resolv.conf".text = ''
    nameserver 114.114.114.114
    options edns0
  '';

  lantian.netns.netease = {
    ipSuffix = "2";
  };

  systemd.services = {
    unblock-netease-music = {
      description = "Unblock NetEase Music";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];

      environment.HOME = "/var/cache/unblock-netease-music";
      path = with pkgs; [
        bash
        nodejs
      ];

      serviceConfig = LT.serviceHarden // {
        Restart = "always";
        RestartSec = "3";

        ExecStart =
          "${pkgs.nodejs}/bin/npx -p @unblockneteasemusic/server unblockneteasemusic"
          + " -p ${LT.portStr.NeteaseUnlock.HTTP}:${LT.portStr.NeteaseUnlock.HTTPS}"
          + " -a ${LT.this.ltnet.IPv4}";

        CacheDirectory = "unblock-netease-music";
        WorkingDirectory = "/var/cache/unblock-netease-music";

        User = "unblock-netease-music";
        Group = "unblock-netease-music";
        MemoryDenyWriteExecute = lib.mkForce false;
      };
    };
  };

  security.wrappers.netease-cloud-music = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
    source = pkgs.writeShellScript "netease-cloud-music" ''
      ${pkgs.netns-exec}/bin/netns-exec-dbus -- netease \
        env \
          QT_AUTO_SCREEN_SCALE_FACTOR=$QT_AUTO_SCREEN_SCALE_FACTOR \
          QT_SCREEN_SCALE_FACTORS=$QT_SCREEN_SCALE_FACTORS \
          XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
        ${netease-cloud-music}/bin/netease-cloud-music \
        --ignore-certificate-errors
    '';
  };

  users.users.unblock-netease-music = {
    group = "unblock-netease-music";
    isSystemUser = true;
  };
  users.groups.unblock-netease-music = { };
}
