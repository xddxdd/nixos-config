{
  lib,
  ...
}: v:
v.tags ++ [v.system] ++ (lib.optional (!v.manualDeploy) "default")
