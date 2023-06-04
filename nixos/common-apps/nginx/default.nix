{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [
    ./autoconfig.nix
    ./libravatar.nix
    ./nginx.nix
    ./oauth2-proxy.nix
    ./proxy.nix
    ./testssl.nix
    ./vhost-tools
    ./vhosts.nix
    ./whois-server.nix
  ];
}
