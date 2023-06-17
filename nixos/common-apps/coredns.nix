{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  netns = config.lantian.netns.coredns-client;

  backupDNSServers = [
    "8.8.8.8"
    "2001:4860:4860::8888"
  ];
in {
  networking.nameservers = [config.lantian.netns.coredns-client.ipv4] ++ backupDNSServers;

  lantian.netns.coredns-client = {
    ipSuffix = "56";
  };

  services.coredns = {
    enable = true;
    package = pkgs.lantianCustomized.coredns;

    config = let
      forwardToGoogleDNS = zone: ''
        ${zone} {
          any
          bufsize 1232
          loadbalance round_robin

          forward . tls://8.8.8.8 tls://8.8.4.4 tls://2001:4860:4860::8888 tls://2001:4860:4860::8844 {
            tls_servername dns.google
          }
          cache
        }
      '';
      forwardTo114DNS = zone: ''
        ${zone} {
          any
          bufsize 1232
          loadbalance round_robin

          forward . 114.114.114.114 114.114.115.115 {
            tls_servername dns.google
          }
          cache
        }
      '';
      forwardToLtnet = zone: ''
        ${zone} {
          any
          bufsize 1232
          loadbalance round_robin

          forward . 198.19.0.253 fdbc:f9dc:67ad:2547::53
          cache
        }
      '';
      mdns = zone: ''
        ${zone} {
          mdns ${zone} 1
        }
      '';

      cfgEntries =
        [
          (forwardToGoogleDNS ".")
          (forwardTo114DNS "kuxi.tech")
        ]
        # Not working well
        # ++ lib.optional config.services.avahi.enable (mdns "local")
        ++ (builtins.map forwardToLtnet
          (with LT.constants.zones; (DN42 ++ NeoNetwork ++ OpenNIC ++ Emercoin ++ CRXN ++ Ltnet)));
    in
      builtins.concatStringsSep "\n" (cfgEntries ++ [""]);
  };

  systemd.services.coredns = netns.bind {};
}
