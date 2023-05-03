{inputs, ...}: final: prev: let
  sources = final.callPackage ../helpers/_sources/generated.nix {};
in rec {
  hostapd = prev.hostapd.overrideAttrs (old: {
    inherit (sources.hostapd) version src;
    extraConfig =
      (old.extraConfig or "")
      + ''
        CONFIG_IEEE80211AX=y
      '';
  });
  linux-firmware = prev.linux-firmware.overrideAttrs (old: {
    preInstall =
      (old.preInstall or "")
      + ''
        cp -r ${sources.openwrt-mt76.src}/firmware/* mediatek/
      '';
    outputHash = null;
    outputHashAlgo = null;
    outputHashMode = null;
  });
}
