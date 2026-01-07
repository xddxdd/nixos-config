{
  pkgs,
  lib,
  LT,
  ...
}:
{
  services.postgresql = {
    enable = true;
    enableJIT = true;
    package = pkgs.postgresql_18_jit;
    extensions =
      ps: with ps; [
        pgvector
        vectorchord
      ];
    settings.listen_addresses = lib.mkForce (
      lib.concatStringsSep ", " [
        "127.0.0.1"
        "::1"
        LT.this.ltnet.IPv4
        LT.this.ltnet.IPv6
      ]
    );
    authentication = ''
      host all all 198.18.0.0/15 md5
      host all all fdbc:f9dc:67ad::/48 md5
    '';
  };

  systemd.services.postgresql.serviceConfig = LT.serviceHarden;

  services.prometheus.exporters.postgres = {
    enable = true;
    port = LT.port.Prometheus.PostgresExporter;
    listenAddress = LT.this.ltnet.IPv4;
    runAsLocalSuperUser = true;
  };
}
