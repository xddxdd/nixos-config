{ lib, ... }:
v:
v.tags
++ [ v.system ]
++ (lib.optional (!v.manualDeploy) "default")
++ (lib.optional (v.hostname != "127.0.0.1") "non-local")
