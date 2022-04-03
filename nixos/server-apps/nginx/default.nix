{ config, pkgs, lib, ... }:

{
  imports = [
    ./nginx.nix
    ./oauth2-proxy.nix
    ./proxy.nix
    ./vhosts.nix
    ./whois-server.nix
  ];
}
