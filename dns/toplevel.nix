{ pkgs, dns, ... }:

with dns;
dns.eval {
  providers = {
    bind = "BIND";
    cloudflare = "CLOUDFLAREAPI";
    desec = "DESEC";
    henet = "HEDNS";
  };
  domains = import ./domains.nix { inherit pkgs dns; };
}
