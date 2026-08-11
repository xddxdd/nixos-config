{
  LT,
  config,
  ...
}:
{
  services.ncps = {
    enable = true;
    server.addr = "192.168.0.4:${LT.portStr.Ncps}";
    cache = {
      inherit (config.networking) hostName;
      lru.schedule = "53 4 * * *";
      maxSize = "100G";
      signNarinfo = false;
      upstream = {
        urls = [ "https://cache.nixos.org" ] ++ LT.constants.nix.substituters;
        publicKeys = LT.constants.nix.trusted-public-keys;
      };
    };
  };
}
