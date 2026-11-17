{ LT, lib, ... }:
let
  local = lib.listToAttrs (map (p: lib.nameValuePair (builtins.baseNameOf p) p) (LT.ls ./skills));

  # Upstream repos are linked skill by skill, not wholesale: the rest of each
  # repository (docs, other skills) stays out of the shared directory.
  upstream = {
    skill-creator = "${LT.sources.anthropic-skills.src}/skills/skill-creator";
    grilling = "${LT.sources.mattpocock-skills.src}/skills/productivity/grilling";
    grill-me = "${LT.sources.mattpocock-skills.src}/skills/productivity/grill-me";
  };
in
{
  home.file = lib.mapAttrs' (
    name: path:
    lib.nameValuePair ".agents/skills/${name}" {
      source = path;
      recursive = true;
    }
  ) (local // upstream);
}
