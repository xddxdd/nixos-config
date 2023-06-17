{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  inherit (LT.this) hostname sshPort tags manualDeploy system;
in {
  deployment = {
    allowLocalDeployment = builtins.elem LT.tags.client tags;
    targetHost = hostname;
    targetPort = sshPort;
    targetUser = "root";
    tags = tags ++ [system] ++ (lib.optional (!manualDeploy) "default");
  };
}
