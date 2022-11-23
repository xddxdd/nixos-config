{ pkgs, lib, config, utils, inputs, ... }@args:

{
  imports = [
    ./ingress-proxy.nix
    ./libravatar.nix
    ./nginx.nix
    ./oauth2-proxy.nix
    ./proxy.nix
    ./testssl.nix
    ./vhosts.nix
    ./whois-server.nix
  ];
}
