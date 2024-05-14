{ LT, ... }:
let
  inherit (LT.this) hostname sshPort hasTag;
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
