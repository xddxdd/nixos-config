{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  netns = config.lantian.netns.coredns-client;
in
lib.mkIf (!config.services.pdns-recursor.enable) {
  networking.nameservers = lib.mkBefore [ netns.ipv4 ];

  lantian.netns.coredns-client = {
    ipSuffix = "56";
  };

  services.coredns = {
    enable = true;
    package = pkgs.nur-xddxdd.lantianCustomized.coredns;

    config =
      let
        forwardToGoogleDNS = zone: ''
          ${zone} {
            any
            bufsize 1232
            loadbalance round_robin
            prometheus ${config.lantian.netns.coredns-client.ipv4}:${LT.portStr.Prometheus.CoreDNS}

            forward . tls://8.8.8.8 tls://8.8.4.4 tls://2001:4860:4860::8888 tls://2001:4860:4860::8844 {
              tls_servername dns.google
            }
            cache
          }
        '';
        forwardToResolvConf = zone: ''
          ${zone} {
            any
            bufsize 1232
            loadbalance round_robin
            prometheus ${config.lantian.netns.coredns-client.ipv4}:${LT.portStr.Prometheus.CoreDNS}

            forward . ${lib.optionalString config.networking.networkmanager.enable "/run/NetworkManager/no-stub-resolv.conf"} 8.8.8.8 {
              prefer_udp
              policy sequential
            }
            cache
          }
        '';
        forwardToLtnet = zone: ''
          ${zone} {
            any
            bufsize 1232
            loadbalance round_robin
            prometheus ${config.lantian.netns.coredns-client.ipv4}:${LT.portStr.Prometheus.CoreDNS}

            forward . 198.19.0.253 fdbc:f9dc:67ad:2547::53
          }
        '';
        block = zone: ''
          ${zone} {
            any
            prometheus ${config.lantian.netns.coredns-client.ipv4}:${LT.portStr.Prometheus.CoreDNS}
            acl { filter net * }
          }
        '';

        defaultForwarder =
          if config.networking.networkmanager.enable then forwardToResolvConf else forwardToGoogleDNS;

        cfgEntries = [
          (defaultForwarder ".")
          # Block Bilibili PCDN https://linux.do/t/topic/534704/7?u=xuyh0120
          (block "mcdn.bilivideo.cn")
          (block "szbdyd.com")
        ]
        # Not working well
        # ++ lib.optional config.services.avahi.enable (mdns "local")
        ++ (builtins.map forwardToLtnet (
          with LT.constants.zones;
          (DN42 ++ NeoNetwork ++ OpenNIC ++ Emercoin ++ CRXN ++ Meshname ++ YggdrasilAlfis ++ Ltnet ++ Others)
        ));
      in
      lib.concatStrings cfgEntries;
  };

  systemd.services.coredns = netns.bind {
    serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = lib.mkForce "5";
    };
  };
}
