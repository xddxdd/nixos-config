{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  inherit (pkgs.python3Packages) mitogen;
in {
  environment.systemPackages = with pkgs; [
    ansible
    mitogen
  ];

  environment.etc."ansible/ansible.cfg".text = ''
    [defaults]
    gathering = explicit
    host_key_checking = False
    strategy_plugins = ${mitogen}/lib/python${pkgs.python3Minimal.pythonVersion}/site-packages/ansible_mitogen/plugins/strategy
    strategy = mitogen_linear
    interpreter_python = auto_silent
    [ssh_connection]
    pipelining = True
    transfer_method = scp
    retries = 3
  '';

  environment.etc."ansible/hosts".text =
    lib.concatStringsSep
    "\n"
    (["[all]"] ++ (builtins.map (n: n + ".lantian.pub") (lib.attrNames LT.otherHosts)));
}
