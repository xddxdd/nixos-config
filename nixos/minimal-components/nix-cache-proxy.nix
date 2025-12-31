{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  nix-cache-proxy = pkgs.callPackage ../../pkgs/nix-cache-proxy { };
  upstreamArgs = lib.concatMapStringsSep " " (u: "--upstream ${u}") (
    [ "https://cache.nixos.org" ] ++ config.nix.settings.trusted-substituters
  );
in
{
  systemd.services.nix-cache-proxy = {
    description = "Nix Cache Proxy";
    after = [ "network.target" ];
    requires = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${nix-cache-proxy}/bin/nix-cache-proxy --bind 127.0.0.1:${LT.portStr.NixCacheProxy} ${upstreamArgs}";

      User = "nix-cache-proxy";
      Group = "nix-cache-proxy";
    };
  };

  users.users.nix-cache-proxy = {
    group = "nix-cache-proxy";
    isSystemUser = true;
  };
  users.groups.nix-cache-proxy = { };
}
