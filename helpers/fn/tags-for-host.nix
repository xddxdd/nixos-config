{ lib, ... }:
v:
v.tags
++ [ v.system ]
++ (lib.optional (!v.manualDeploy) "default")
++ (lib.optional (!v.manualDeploy && v.hostname != "127.0.0.1") "default-non-local")
