{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  netns = config.lantian.netns.step-ca;
in {
  lantian.netns.step-ca = {
    ipSuffix = "31";
    birdBindTo = ["step-ca.service"];
  };

  systemd.services."step-ca" = netns.bind {
    description = "Step-CA";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      HOME = "/var/lib/step-ca";
      STEPPATH = "/var/lib/step-ca";
    };
    serviceConfig =
      LT.serviceHarden
      // {
        User = "step-ca";
        Group = "step-ca";
        UMask = "0077";
        WorkingDirectory = "/var/lib/step-ca";
        StateDirectory = "step-ca";

        ExecStart = "${pkgs.step-ca}/bin/step-ca /var/lib/step-ca/config/ca.json --password-file /var/lib/step-ca/password.txt";

        AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
        CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
      };
  };

  services.nginx.virtualHosts."ca.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf {} {
      "/".proxyPass = "https://${netns.ipv4}:443";
    };
    extraConfig =
      LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };

  users.users.step-ca = {
    home = "/var/lib/step-ca";
    group = "step-ca";
    isSystemUser = true;
  };
  users.groups.step-ca = {};
}
