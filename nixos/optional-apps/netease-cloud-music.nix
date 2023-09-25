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

  netease-cloud-music = pkgs.nur.repos.Freed-Wu.netease-cloud-music;
in {
  virtualisation.oci-containers.containers.unblock-netease-music = {
    extraOptions = ["--net" "host" "--pull" "always"];
    image = "pan93412/unblock-netease-music-enhanced:release";
    cmd = [
      "-p"
      "${LT.portStr.NeteaseUnlock.HTTP}:${LT.portStr.NeteaseUnlock.HTTPS}"
      "-a"
      "${LT.this.ltnet.IPv4}"
    ];
  };

  environment.systemPackages = [netease-cloud-music];

  environment.etc."netns/netease/resolv.conf".text = ''
    nameserver 114.114.114.114
    options edns0
  '';

  lantian.netns.netease = {
    ipSuffix = "2";
  };

  systemd.services = {
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
}
