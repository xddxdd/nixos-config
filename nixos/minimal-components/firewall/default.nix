{
  pkgs,
  LT,
  config,
  ...
}:
let
  # Cannot use NixOS's services.nftables, it requires disable iptables
  # and will conflict with docker
  nftRules = pkgs.callPackage ./nft-rules.nix { inherit LT config; };
in
{
  systemd.services.nftables = {
    description = "Nftables rules";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      After = "network.target";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nftables}/bin/nft -f ${nftRules}";
    };
  };
}
