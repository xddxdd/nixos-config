{ config, pkgs, ... }:

let
  LT = import ../helpers.nix {  inherit config pkgs; };
  mitogen = pkgs.python39Packages.mitogen;
in
{
  environment.systemPackages = with pkgs; [
    ansible_2_10
    mitogen
  ];

  environment.etc."ansible/ansible.cfg".text = ''
    [defaults]
    gathering = explicit
    host_key_checking = False
    strategy_plugins = ${mitogen}/lib/python3.9/site-packages/ansible_mitogen/plugins/strategy
    strategy = mitogen_linear
    interpreter_python = auto_silent
    [ssh_connection]
    pipelining = True
    transfer_method = scp
    retries = 3
  '';

  environment.etc."ansible/hosts".text = pkgs.lib.concatStringsSep
    "\n"
    ([ "[all]" ] ++ (pkgs.lib.mapAttrsToList (n: v: n + ".lantian.pub") LT.hosts));

  programs.ssh.extraConfig = ''
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    VerifyHostKeyDNS yes
    LogLevel ERROR

    Host git.lantian.pub
      User git
      Port 22

    Host *.lantian.pub
      User root
      Port 2222
  '';
}
