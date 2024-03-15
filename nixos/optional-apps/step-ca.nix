{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  imports = [ ./postgresql.nix ];

  systemd.services."step-ca" = {
    description = "Step-CA";
    after = [
      "network.target"
      "postgresql.service"
    ];
    requires = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      HOME = "/var/lib/step-ca";
      STEPPATH = "/var/lib/step-ca";
    };
    serviceConfig = LT.serviceHarden // {
      User = "step-ca";
      Group = "step-ca";
      UMask = "0077";
      WorkingDirectory = "/var/lib/step-ca";
      StateDirectory = "step-ca";

      ExecStart = "${pkgs.step-ca}/bin/step-ca /var/lib/step-ca/config/ca.json --password-file /var/lib/step-ca/password.txt";

      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };

  lantian.nginxVhosts."ca.lantian.pub" = {
    locations = {
      "/".return = "https://ca.lantian.pub:444$request_uri";
    };

    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
  };

  services.postgresql = {
    ensureDatabases = [ "step-ca" ];
    ensureUsers = [
      {
        name = "step-ca";
        ensureDBOwnership = true;
      }
    ];
  };

  users.users.step-ca = {
    home = "/var/lib/step-ca";
    group = "step-ca";
    isSystemUser = true;
  };
  users.groups.step-ca = { };
}
