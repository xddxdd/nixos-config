{
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  age.secrets.oauth2-proxy-conf.file = inputs.secrets + "/oauth2-proxy-conf.age";

  services.oauth2-proxy = {
    enable = true;
    clientID = "oauth-proxy";
    cookie = {
      expire = "24h";
    };
    email.domains = [ "*" ];
    httpAddress = "unix:///run/oauth2-proxy/oauth2-proxy.sock";
    keyFile = config.age.secrets.oauth2-proxy-conf.path;
    provider = "oidc";
    setXauthrequest = true;
    extraConfig = {
      code-challenge-method = "S256";
      cookie-csrf-expire = "15m";
      cookie-csrf-per-request = true;
      oidc-issuer-url = "https://login.lantian.pub";
      insecure-oidc-skip-issuer-verification = "true";
      insecure-oidc-allow-unverified-email = "true";
      scope = "openid profile email groups";
      whitelist-domain = [
        "lantian.pub"
        "*.lantian.pub"
        "xuyh0120.win"
        "*.xuyh0120.win"
      ];
    };
  };
  users.users.oauth2-proxy = {
    group = "oauth2-proxy";
    isSystemUser = true;
  };
  users.groups.oauth2-proxy.members = [ "nginx" ];

  systemd.services.oauth2-proxy = {
    unitConfig = {
      After = lib.mkForce "network.target nginx.service";
    };
    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "3";
      RuntimeDirectory = "oauth2-proxy";
      UMask = "007";
    };
  };
}
