{
  lib,
  pkgs,
  LT,
  ...
}:
let
  picoclaw = pkgs.llm-agents.picoclaw.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace pkg/tools/shell.go \
        --replace-fail "t.guardCommand(command, cwd)" '""'
    '';
    doCheck = false;
    doInstallCheck = false;
  });
in
{
  environment.systemPackages = [
    pkgs.github-cli
    picoclaw
  ];

  systemd.services.picoclaw = {
    description = "PicoClaw";
    wantedBy = [ "multi-user.target" ];

    script = ''
      export PATH=/run/current-system/sw/bin:$PATH
      exec ${lib.getExe picoclaw} gateway
    '';

    serviceConfig = LT.serviceHarden // {
      User = "picoclaw";
      Group = "picoclaw";

      MemoryDenyWriteExecute = false;
      StateDirectory = "picoclaw";

      Restart = "always";
      RestartSec = "5";
    };
  };

  users.users.picoclaw = {
    group = "picoclaw";
    isSystemUser = true;
    home = "/var/lib/picoclaw";
  };
  users.groups.picoclaw = { };
}
