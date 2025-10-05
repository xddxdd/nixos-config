{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  sshKeys = import (inputs.secrets + "/ssh/btrbk.nix");
in
{
  options.lantian.btrbk.storage = lib.mkOption {
    type = lib.types.str;
    default = "/nix/persistent/backups/btrbk";
    description = "Storage path for Btrbk";
  };

  config = {
    environment.systemPackages = [ pkgs.zstd ];

    systemd.tmpfiles.settings = {
      btrbk = {
        "${config.lantian.btrbk.storage}".d = {
          mode = "700";
          user = "btrbk";
          group = "btrbk";
        };
      };
    };
    services.btrbk.sshAccess = builtins.map (k: {
      key = k;
      roles = [
        "source"
        "target"
        "info"
        "snapshot"
        "send"
        "receive"
      ];
    }) sshKeys;

    users.users.btrbk.extraGroups = [ "wheel" ];
  };
}
