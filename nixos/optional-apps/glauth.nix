{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  glauthUsers = import (pkgs.secrets + "/glauth-users.nix");

  cfg = pkgs.writeText "glauth.cfg" ''
    [ldap]
      enabled = true
      listen = "${LT.this.ltnet.IPv4}:389"

    [ldaps]
      enabled = true
      listen = "${LT.this.ltnet.IPv4}:636"
      cert = "${LT.nginx.getSSLCert "lantian.pub_ecc"}"
      key = "${LT.nginx.getSSLKey "lantian.pub_ecc"}"

    [[backends]]
      datastore = "config"
      baseDN = "dc=lantian,dc=pub"

    [behaviors]
      IgnoreCapabilities = false
      LimitFailedBinds = false

    [[users]]
      name = "lantian"
      givenname = "Lan"
      sn = "Tian"
      mail = "${glauthUsers.lantian.mail}"
      uidnumber = 1000
      primarygroup = 100
      passbcrypt = "${glauthUsers.lantian.passbcrypt}"

    [[users]]
      name = "serviceuser"
      mail = "serviceuser@example.com"
      uidnumber = 60000
      primarygroup = 60000
      passbcrypt = "${glauthUsers.serviceuser.passbcrypt}"
      [[users.capabilities]]
        action = "search"
        object = "*"

    [[groups]]
      name = "admin"
      gidnumber = 100

    [[groups]]
      name = "svcaccts"
      gidnumber = 60000

    [api]
      enabled = false
  '';
in
{
  systemd.services.glauth = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.glauth}/bin/glauth -c ${cfg}";
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };
}
