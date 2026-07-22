{ LT, ... }:
{
  services.actual = {
    enable = true;
    settings = {
      hostname = "127.0.0.1";
      port = LT.port.Actual;
    };
  };

  lantian.nginxVhosts."actual.xuyh0120.win" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.Actual}";
      # Budget sync/upload can be large and long-running.
      # COOP/COEP headers required for SharedArrayBuffer are set by the app
      # itself and passed through untouched.
      proxyNoTimeout = true;
    };

    sslCertificate = "zerossl-xuyh0120.win";
    noIndex.enable = true;
  };
}
