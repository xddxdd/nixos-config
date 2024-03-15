{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  age.secrets.oauth2-proxy-conf.file = inputs.secrets + "/oauth2-proxy-conf.age";

  services.oauth2_proxy = {
    enable = true;
    clientID = "oauth-proxy";
    cookie = {
      expire = "24h";
    };
    email.domains = [ "*" ];
    httpAddress = "unix:///run/oauth2_proxy/oauth2_proxy.sock";
    keyFile = config.age.secrets.oauth2-proxy-conf.path;
    provider = "oidc";
    setXauthrequest = true;
    extraConfig = {
      oidc-issuer-url = "https://login.lantian.pub/realms/master";
      insecure-oidc-skip-issuer-verification = "true";
      insecure-oidc-allow-unverified-email = "true";
    };
  };
  users.users.oauth2_proxy.group = "oauth2_proxy";
  users.groups.oauth2_proxy.members = [ "nginx" ];

  systemd.services.oauth2_proxy = {
    unitConfig = {
      After = lib.mkForce "network.target nginx.service";
    };
    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "3";
      RuntimeDirectory = "oauth2_proxy";
      UMask = "007";
    };
  };
}
