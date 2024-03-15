{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  netns = config.lantian.netns.cf-warp;

  warp-cli = pkgs.writeShellScriptBin "warp-cli" ''
    /run/wrappers/bin/netns-exec cf-warp ${pkgs.cloudflare-warp}/bin/warp-cli "$@"
  '';

  v2rayConf = pkgs.writeText "config.json" (
    builtins.toJSON {
      inbounds = [
        {
          listen = netns.ipv4;
          port = 1080;
          protocol = "socks";
          settings.udp = true;
        }
      ];
      log = {
        access = "none";
        loglevel = "warning";
      };
      outbounds = [
        {
          protocol = "freedom";
          tag = "direct";
        }
      ];
    }
  );
in
{
  lantian.netns.cf-warp = {
    ipSuffix = "193";
  };

  environment.etc."netns/cf-warp/resolv.conf".text = ''
    ${lib.concatMapStringsSep "\n" (d: "nameserver ${d}") config.networking.nameservers}
    options single-request edns0
  '';

  environment.systemPackages = [ warp-cli ];

  systemd.services.cloudflare-warp = netns.bind {
    description = "Cloudflare Warp";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    requires = [ "network.target" ];

    path = with pkgs; [
      lsof
      nftables-fullcone
    ];

    preStart = ''
      cat > /etc/resolv.conf <<EOF
      ${lib.concatMapStringsSep "\n" (d: "nameserver ${d}") config.networking.nameservers}
      options single-request edns0
      EOF
    '';

    postStart = ''
      set -x
      while [ ! -S /run/cloudflare-warp/warp_service ]; do sleep 1; done
      if [ ! -f /var/lib/cloudflare-warp/reg.json ]; then
        ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos register
      fi
      ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos connect
      ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos set-mode warp+doh
      ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos disable-connectivity-checks
      ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos add-excluded-route 198.18.0.0/15
    '';

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
      CacheDirectory = "cloudflare-warp";
      StateDirectory = "cloudflare-warp";
      RuntimeDirectory = "cloudflare-warp";
      LogsDirectory = "cloudflare-warp";

      User = "cloudflare-warp";
      Group = "cloudflare-warp";

      AmbientCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
        "CAP_SYS_PTRACE"
      ];
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
        "CAP_SYS_PTRACE"
      ];
      PrivateDevices = false;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      SystemCallFilter = lib.mkForce [ ];
      BindPaths = [ "/var/cache/cloudflare-warp:/etc" ];
    };
  };

  systemd.services.cloudflare-warp-v2ray = netns.bind {
    description = "v2ray Daemon for Cloudflare Warp";
    after = [
      "network.target"
      "cloudflare-warp.service"
    ];
    requires = [
      "network.target"
      "cloudflare-warp.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = LT.serviceHarden // {
      User = "nginx";
      Group = "nginx";
      RuntimeDirectory = "v2ray-cf-warp";
      ExecStart = "${pkgs.xray}/bin/xray -config ${v2rayConf}";
      BindPaths = [ "/var/cache/cloudflare-warp:/etc" ];
    };
  };

  users.users.cloudflare-warp = {
    group = "cloudflare-warp";
    isSystemUser = true;
  };
  users.groups.cloudflare-warp = { };
}
