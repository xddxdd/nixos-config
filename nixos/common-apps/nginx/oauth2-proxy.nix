{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs lib; };
in
{
  age.secrets.oauth2-proxy-conf.file = pkgs.secrets + "/oauth2-proxy-conf.age";

  services.oauth2_proxy = {
    enable = true;
    clientID = "oauth-proxy";
    cookie = {
      expire = "24h";
    };
    email.domains = [ "*" ];
    httpAddress = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Oauth2Proxy}";
    keyFile = config.age.secrets.oauth2-proxy-conf.path;
    provider = "oidc";
    setXauthrequest = true;
    extraConfig = {
      oidc-issuer-url = "https://login.xuyh0120.win";
      insecure-oidc-skip-issuer-verification = "true";
      insecure-oidc-allow-unverified-email = "true";
    };
  };
  users.users.oauth2_proxy.group = "oauth2_proxy";
  users.groups.oauth2_proxy = { };

  systemd.services.oauth2_proxy = {
    unitConfig = {
      After = lib.mkForce "network.target nginx.service";
    };
    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "3";
      DynamicUser = true;
    };
  };
}
