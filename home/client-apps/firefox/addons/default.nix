{
  lib,
  pkgs,
  ...
}:
let
  buildAddon =
    {
      pname,
      version,
      url,
      hash,
      addonId,
    }:
    pkgs.runCommandLocal "firefox-addon-${pname}-${version}"
      {
        src = pkgs.fetchurl { inherit url hash; };
        passthru.addonId = addonId;
        meta = {
          addonName = pname;
          platform = lib.platforms.all;
        };
      }
      ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';

  addons = builtins.fromJSON (builtins.readFile ./addons.json);
in
lib.listToAttrs (map (addon: lib.nameValuePair addon.pname (buildAddon addon)) addons)
