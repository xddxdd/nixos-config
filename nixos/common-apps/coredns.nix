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
{
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

            forward . /run/NetworkManager/no-stub-resolv.conf 8.8.8.8 {
              prefer_udp
              policy sequential
            }
            cache
          }
        '';
        forwardTo114DNS = zone: ''
          ${zone} {
            any
            bufsize 1232
            loadbalance round_robin
            prometheus ${config.lantian.netns.coredns-client.ipv4}:${LT.portStr.Prometheus.CoreDNS}

            forward . 114.114.114.114 114.114.115.115
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
            cache
          }
        '';
        forwardToAzurePrivateDNS = zone: ''
          ${zone} {
            any
            bufsize 1232
            loadbalance round_robin
            prometheus ${config.lantian.netns.coredns-client.ipv4}:${LT.portStr.Prometheus.CoreDNS}

            forward . 168.63.129.16
            cache
          }
        '';
        block = zone: ''
          ${zone} {
            any
            prometheus ${config.lantian.netns.coredns-client.ipv4}:${LT.portStr.Prometheus.CoreDNS}
            hosts {
              0.0.0.0 ${zone}
            }
          }
        '';

        cfgEntries =
          [
            ((if config.networking.networkmanager.enable then forwardToResolvConf else forwardToGoogleDNS) ".")
            (forwardTo114DNS "kuxi.tech")
            (forwardToAzurePrivateDNS "database.azure.com")
            (block "upos-sz-mirroraliov.bilivideo.com")
          ]
          # Not working well
          # ++ lib.optional config.services.avahi.enable (mdns "local")
          ++ (builtins.map forwardToLtnet (
            with LT.constants.zones; (DN42 ++ NeoNetwork ++ OpenNIC ++ Emercoin ++ CRXN ++ Ltnet)
          ));
      in
      lib.concatStrings cfgEntries;
  };

  systemd.services.coredns = netns.bind { };
}
