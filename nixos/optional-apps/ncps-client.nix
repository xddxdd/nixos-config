{ LT, lib, ... }:
{
  services.nix-cache-proxy.enable = lib.mkForce false;
  nix.settings.substituters = lib.mkForce [ "http://192.168.0.4:${LT.portStr.Ncps}" ];
}
