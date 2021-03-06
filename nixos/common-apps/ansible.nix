{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
  mitogen = pkgs.python39Packages.mitogen;
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
    strategy_plugins = ${mitogen}/lib/python${pkgs.python3Minimal.pythonVersion}/site-packages/ansible_mitogen/plugins/strategy
    strategy = mitogen_linear
    interpreter_python = auto_silent
    [ssh_connection]
    pipelining = True
    transfer_method = scp
    retries = 3
  '';

  environment.etc."ansible/hosts".text = lib.concatStringsSep
    "\n"
    ([ "[all]" ] ++ (lib.mapAttrsToList (n: v: n + ".lantian.pub") LT.serverHosts));

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
