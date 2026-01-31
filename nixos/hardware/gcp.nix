{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [ ./qemu.nix ];

  networking.hosts."169.254.169.254" = [
    "metadata.google.internal"
    "metadata"
  ];

  systemd.packages = [ pkgs.google-guest-agent ];
  systemd.services.google-guest-agent = {
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ config.environment.etc."default/instance_configs.cfg".source ];
    path = lib.optional config.users.mutableUsers pkgs.shadow;
  };
  systemd.services.google-startup-scripts.wantedBy = [ "multi-user.target" ];
  systemd.services.google-shutdown-scripts.wantedBy = [ "multi-user.target" ];

  environment.etc."default/instance_configs.cfg".text = ''
    [Accounts]
    useradd_cmd = useradd -m -s /run/current-system/sw/bin/bash -p * {user}

    [Daemons]
    accounts_daemon = ${lib.boolToString config.users.mutableUsers}

    [InstanceSetup]
    # Make sure GCE image does not replace host key that NixOps sets.
    set_host_keys = false

    [MetadataScripts]
    default_shell = ${pkgs.stdenv.shell}

    [NetworkInterfaces]
    dhclient_script = ${pkgs.google-guest-configs}/bin/google-dhclient-script
    # We set up network interfaces declaratively.
    setup = false
  '';
}
