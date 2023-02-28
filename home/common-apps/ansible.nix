{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
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

  xdg.configFile."ansible/hosts".text =
    lib.concatStringsSep
    "\n"
    (["[all]"] ++ (builtins.map (n: n + ".lantian.pub") (lib.attrNames LT.serverHosts)));

  home.sessionVariables.ANSIBLE_CONFIG = "${config.home.homeDirectory}/.config/ansible/ansible.cfg";
}
