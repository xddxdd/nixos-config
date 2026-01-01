{
  LT,
  config,
  ...
}:
{
  services.nix-cache-proxy = {
    enable = true;
    listenAddress = "127.0.0.1:${LT.portStr.NixCacheProxy}";
    upstreams = [ "https://cache.nixos.org" ] ++ config.nix.settings.trusted-substituters;
  };
}
