{ lib, ... }:
v:
v.tags
++ [ v.system ]
++ (lib.optional (!v.manualDeploy) "default")
++ [ "all" ]
++ (lib.optional (!v.manualDeploy && v.hostname != "127.0.0.1") "default-non-local")
++ (lib.optional (v.hostname != "127.0.0.1") "non-local")
