{
  pkgs,
  lib,
  LT,
  ...
}:
let
  inherit (pkgs.python3Packages) mitogen;
in
{
  environment.systemPackages = with pkgs; [
    ansible
    mitogen
  ];

  environment.etc."ansible/ansible.cfg".text = ''
    [defaults]
    gathering = explicit
    host_key_checking = False
    strategy_plugins = ${mitogen}/${pkgs.python3.sitePackages}/ansible_mitogen/plugins/strategy
    strategy = mitogen_linear
    interpreter_python = auto_silent
    [ssh_connection]
    pipelining = True
    transfer_method = scp
    retries = 3
  '';

  environment.etc."ansible/hosts".text = lib.concatStringsSep "\n" (
    [ "[all]" ]
    ++ (builtins.map (n: n + ".lantian.pub") (
      lib.attrNames (lib.filterAttrs (k: v: !v.manualDeploy) LT.otherHosts)
    ))
  );

  environment.variables.ANSIBLE_CONFIG = "/etc/ansible/ansible.cfg";
}
