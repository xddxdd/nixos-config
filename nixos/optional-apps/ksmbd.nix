{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  smbToString = x:
    if builtins.typeOf x == "bool"
    then (if x then "yes" else "no")
    else builtins.toString x;

  ksmbdConfig = lib.recursiveUpdate
    {
      global = {
        "deadtime" = 3600;
        "map to guest" = "bad user";
        "netbios name" = config.networking.hostName;
        "restrict anonymous" = 1;
        "server string" = config.networking.hostName;
      };
    }
    config.services.ksmbd.config;

  configText = builtins.concatStringsSep "\n" (lib.mapAttrsToList
    (k: v: ''
      [${k}]
      ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k} = ${smbToString v}") v)}
    '')
    ksmbdConfig);
in
{
  options = {
    services.ksmbd = {
      enable = lib.mkEnableOption "Enable Kernel SMBD";

      config = lib.mkOption {
        default = { };
        description = "Shared resources";
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.unspecified);
      };
    };
  };

  config = {
    environment.etc."ksmbd/smb.conf".text = configText;

    environment.systemPackages = with pkgs; [ ksmbd-tools ];

    environment.persistence."/nix/persistent" = {
      directories = [
        "/etc/ksmbd"
      ];
    };

    systemd.services.ksmbd = {
      description = "ksmbd userspace daemon";
      requires = [ "modprobe@ksmbd.service" ];
      wants = [ "network-online.target" ];
      after = [ "modprobe@ksmbd.service" "network.target" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "forking";
        PIDFile = "/tmp/ksmbd.lock";
        ExecStart = "${pkgs.ksmbd-tools}/bin/ksmbd.mountd";
        ExecReload = "${pkgs.ksmbd-tools}/bin/ksmbd.control --reload";
        ExecStop = "${pkgs.ksmbd-tools}/bin/ksmbd.control --shutdown";

        Restart = "always";
        RestartSec = "3";
      };
    };
  };
}
