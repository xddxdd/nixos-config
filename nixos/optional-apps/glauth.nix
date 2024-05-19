{
  pkgs,
  LT,
  config,
  inputs,
  ...
}:
let
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");

  hexdump =
    s:
    builtins.readFile (
      pkgs.runCommandLocal "hexdump.txt" { } ''
        echo -n '${s}' | ${pkgs.unixtools.xxd}/bin/xxd -pu | tr -d '\n' > $out
      ''
    );

  cfg = pkgs.writeText "glauth.cfg" ''
    [ldap]
      enabled = true
      listen = "[::]:${LT.portStr.LDAP}"

    [ldaps]
      enabled = true
      listen = "[::]:${LT.portStr.LDAPS}"
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
      passbcrypt = "${hexdump glauthUsers.lantian.passBcrypt}"

    [[users]]
      name = "serviceuser"
      mail = "serviceuser@example.com"
      uidnumber = 60000
      primarygroup = 60000
      passbcrypt = "${hexdump glauthUsers.serviceuser.passBcrypt}"
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

  netns = config.lantian.netns.glauth;
in
{
  lantian.netns.glauth = {
    ipSuffix = "38";
    announcedIPv4 = [
      "198.19.0.38"
      "10.127.10.38"
    ];
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::389"
      "fd10:127:10:2547::389"
    ];
    birdBindTo = [ "glauth.service" ];
  };

  systemd.services.glauth = netns.bind {
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
