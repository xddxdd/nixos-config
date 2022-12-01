{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../../helpers args;

  # Cannot use NixOS's services.nftables, it requires disable iptables
  # and will conflict with docker
  nftRules = pkgs.callPackage ./nft-rules.nix args;
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
      ExecStart = "${pkgs.nftables-fullcone}/bin/nft -f ${nftRules}";
    };
  };
}
