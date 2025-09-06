{
  LT,
  lib,
  ...
}:
{
  virtualisation.oci-containers.containers.byparr = {
    image = "ghcr.io/thephaseless/byparr:main";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    environment = {
      USE_HEADLESS = "false";
      USE_XVFB = "true";
    };
    ports = [ "127.0.0.1:${LT.portStr.FlareSolverr}:8191" ];
  };

  services.flaresolverr.enable = lib.mkForce false;
  # Be absolutely sure we don't have flaresolverr installed
  system.forbiddenDependenciesRegexes = [ "flaresolverr" ];
}
