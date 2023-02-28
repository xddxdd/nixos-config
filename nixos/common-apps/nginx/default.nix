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
    ./libravatar.nix
    ./nginx.nix
    ./oauth2-proxy.nix
    ./proxy.nix
    ./testssl.nix
    ./vhosts.nix
    ./whois-server.nix
  ];
}
