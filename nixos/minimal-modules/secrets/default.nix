{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.lantian.secrets;
  specification = pkgs.writeText "lantian-secrets.json" (builtins.toJSON cfg);
  validPath =
    path:
    lib.hasPrefix "/" path
    && path != "/"
    && !(lib.hasPrefix "/nix/store/" path)
    && lib.all (part: part != "." && part != ".." && part != "") (lib.tail (lib.splitString "/" path));
in
{
  options.lantian.secrets = lib.mkOption {
    default = { };
    description = "Machine-local files generated at runtime, never stored as values in the Nix store.";
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }: {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
              default = "/var/lib/lantian-secrets/${name}";
              description = "Absolute destination with no symlink path components. Existing files must be regular and singly linked. Use persistent storage when the value must survive a reboot.";
            };
            command = lib.mkOption {
              type = lib.types.lines;
              default = "${lib.getExe pkgs.pwgen} -s 64 1";
              description = "Bash command whose stdout becomes the secret. Runs in a private temporary directory. Commands are public store contents: do not embed credentials.";
            };
            owner = lib.mkOption {
              type = lib.types.str;
              default = "root";
            };
            group = lib.mkOption {
              type = lib.types.str;
              default = "root";
            };
            mode = lib.mkOption {
              type = lib.types.strMatching "0?[0-7]{3}";
              default = "0600";
            };
            audit = lib.mkEnableOption "auditing every caller accessing this file with the project auditd component";
          };
        }
      )
    );
  };

  config = lib.mkIf (cfg != { }) {
    assertions = [
      {
        assertion = lib.all (
          secret:
          validPath secret.path && !(lib.hasInfix "\n" secret.path) && !(lib.hasInfix "\r" secret.path)
        ) (lib.attrValues cfg);
        message = "lantian.secrets paths must be normalized absolute non-store file paths.";
      }
      {
        assertion =
          builtins.length (lib.unique (map (secret: secret.path) (lib.attrValues cfg)))
          == builtins.length (lib.attrNames cfg);
        message = "lantian.secrets entries must have distinct destination paths.";
      }
    ];

    systemd.services.lantian-secrets = {
      description = "Generate missing machine-local secrets and enforce their permissions";
      path = [ pkgs.pwgen ];
      environment.TMPDIR = "/run/lantian-secrets";
      wantedBy = [ "sysinit.target" ];
      before = [
        "sysinit.target"
        "audit-rules-nixos.service"
        "shutdown.target"
      ];
      after = [
        "local-fs.target"
        "systemd-sysusers.service"
        "userborn.service"
        "systemd-tmpfiles-setup.service"
      ];
      conflicts = [ "shutdown.target" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "5min";
        ExecStart = "${pkgs.python3}/bin/python3 ${./generate.py} ${specification} ${pkgs.bash}/bin/bash";
        UMask = "0077";
        RuntimeDirectory = "lantian-secrets";
        RuntimeDirectoryMode = "0700";
        StateDirectory = "lantian-secrets";
        StateDirectoryMode = "0711";
        NoNewPrivileges = true;
        CapabilityBoundingSet = [
          "CAP_CHOWN"
          "CAP_DAC_OVERRIDE"
          "CAP_FOWNER"
        ];
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
      };
    };
  };
}
