{ LT, ... }:
{
  lantian.localVhosts.pi = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.PiWeb}";
        proxyWebsockets = true;
        proxyOverrideHost = "pi.localhost";
        proxyOverrideOrigin = "https://pi.localhost";
        proxyNoTimeout = true;
      };
    };
  };
}
