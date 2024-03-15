{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  inherit (LT.this)
    hostname
    sshPort
    hasTag
    manualDeploy
    system
    ;
in
{
  deployment = {
    allowLocalDeployment = hasTag LT.tags.client;
    targetHost = hostname;
    targetPort = sshPort;
    targetUser = "root";
    tags = LT.tagsForHost LT.this;
  };
}
