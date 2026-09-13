{ LT, ... }:
{
  lantian.localVhosts.pi-web = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.PiWeb}";
        proxyWebsockets = true;
        proxyOverrideHost = "pi-web.localhost";
        proxyNoTimeout = true;
      };
    };
  };
}
