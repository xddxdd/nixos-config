{
  LT,
  ...
}:
{
  virtualisation.oci-containers.containers.pyison = {
    image = "ghcr.io/jonaslong/pyison:main";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    ports = [ "127.0.0.1:${LT.portStr.Pyison}:80" ];
  };

  lantian.nginxVhosts."posts.lantian.pub" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Pyison}";
      };
    };

    sslCertificate = "zerossl-lantian.pub";
  };
}
