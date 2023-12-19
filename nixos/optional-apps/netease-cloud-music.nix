{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  netns = config.lantian.netns.netease;

  netease-cloud-music = pkgs.netease-cloud-music;
in {
  environment.systemPackages = [netease-cloud-music];

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
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      requires = ["network-online.target"];

      environment.HOME = "/var/cache/unblock-netease-music";
      path = with pkgs; [bash nodejs];

      serviceConfig =
        LT.serviceHarden
        // {
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

    netns-netease-proxy = {
      after = ["netns-instance-netease.service"];
      bindsTo = ["netns-instance-netease.service"];
      wantedBy = ["multi-user.target"];
      path = with pkgs; [iptables];
      script = ''
        # Redirect all HTTP connection to proxy
        iptables -t nat -A PREROUTING -i ns-netease -p tcp --dport 80 -j DNAT --to-destination ${LT.this.ltnet.IPv4}:${LT.portStr.NeteaseUnlock.HTTP}
        iptables -t nat -A PREROUTING -i ns-netease -p tcp --dport 443 -j DNAT --to-destination ${LT.this.ltnet.IPv4}:${LT.portStr.NeteaseUnlock.HTTPS}
        # Block IPv6 to prevent leaks
        ip6tables -A INPUT -i ns-netease -j REJECT
      '';
      postStop = ''
        iptables -t nat -D PREROUTING -i ns-netease -p tcp --dport 80 -j DNAT --to-destination ${LT.this.ltnet.IPv4}:${LT.portStr.NeteaseUnlock.HTTP}
        iptables -t nat -D PREROUTING -i ns-netease -p tcp --dport 443 -j DNAT --to-destination ${LT.this.ltnet.IPv4}:${LT.portStr.NeteaseUnlock.HTTPS}
        ip6tables -D INPUT -i ns-netease -j REJECT
      '';
      serviceConfig = {
        Type = "forking";
        Restart = "always";
        RestartSec = "10s";
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
  users.groups.unblock-netease-music = {};
}
