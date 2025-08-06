{
  LT,
  config,
  inputs,
  ...
}:
{
  age.secrets.glauth-bindpw = {
    file = inputs.secrets + "/glauth-bindpw.age";
    mode = "0444";
  };

  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "127.0.0.1:${LT.portStr.Radicale}" ];
      auth = {
        type = "ldap";
        ldap_uri = "ldap://[fdbc:f9dc:67ad:2547::389]";
        ldap_base = "dc=lantian,dc=pub";
        ldap_reader_dn = "cn=serviceuser,dc=lantian,dc=pub";
        ldap_secret_file = config.age.secrets.glauth-bindpw.path;
        ldap_filter = "(&(cn={0})(objectClass=posixAccount)(!(ou=svcaccts)))";
        ldap_user_attribute = "cn";
      };
      storage.filesystem_folder = "/var/lib/radicale/collections";
    };
  };

  systemd.services.radicale.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };

  lantian.nginxVhosts."cal.xuyh0120.win" = {
    locations = {
      "/".proxyPass = "http://127.0.0.1:${LT.portStr.Radicale}";
    };

    sslCertificate = "zerossl-xuyh0120.win";
    blockDotfiles = false;
    noIndex.enable = true;
  };
}
