{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs lib; };

  oauth2Proxy = pkgs.buildGoModule rec {
    pname = "oauth2-proxy";
    version = "7.2.1";

    src = pkgs.fetchFromGitHub {
      repo = pname;
      owner = "oauth2-proxy";
      sha256 = "sha256-8hYsyHq0iyWzY/HHE4JWBtlaRcSTyM6BdAPcByThme8=";
      rev = "v${version}";
    };

    vendorSha256 = "sha256-+5/j2lZJpyo67uRRSn4Fd8S2K0gfAGMe69OoEEdWijc=";

    # Taken from https://github.com/oauth2-proxy/oauth2-proxy/blob/master/Makefile
    ldflags = [ "-X main.VERSION=${version}" ];
  };
in
{
  age.secrets.oauth2-proxy-conf.file = pkgs.secrets + "/oauth2-proxy-conf.age";

  services.oauth2_proxy = {
    enable = true;
    package = oauth2Proxy;
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
      oidc-issuer-url = "http://127.0.0.1";
      insecure-oidc-skip-issuer-verification = "true";
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
