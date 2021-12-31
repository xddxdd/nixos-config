{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  hostsList = builtins.filter (k: hosts."${k}".deploy or true) (pkgs.lib.mapAttrsToList (n: v: n) hosts);
in
{
  xdg.configFile."ansible/ansible.cfg".text = ''
    [defaults]
    gathering = explicit
    host_key_checking = False
    interpreter_python = auto_silent
    inventory = ${config.home.homeDirectory}/.config/ansible/hosts
    [ssh_connection]
    pipelining = True
    transfer_method = scp
    retries = 3
  '';

  xdg.configFile."ansible/hosts".text = pkgs.lib.concatStringsSep
    "\n"
    ([ "[all]" ] ++ (builtins.map (n: n + ".lantian.pub") hostsList));

  home.sessionVariables.ANSIBLE_CONFIG = "${config.home.homeDirectory}/.config/ansible/ansible.cfg";
}
