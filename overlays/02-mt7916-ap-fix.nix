{ inputs, ... }:

final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
in
rec {
  hostapd = prev.hostapd.overrideAttrs (old: {
    inherit (sources.hostapd) version src;
    extraConfig = (old.extraConfig or "") + ''
      CONFIG_IEEE80211AX=y
    '';
  });
  linux-firmware = prev.linux-firmware.overrideAttrs (old:
    let
      mt7916TestFirmware = final.fetchzip {
        url = "https://github.com/openwrt/mt76/files/10567955/mt7916_test_fw.zip";
        stripRoot = false;
        hash = "sha256-KgMogC2RAbOS9SIU2wvx5CvQ5+KguxnHx/SH2fm+y7w=";
      };
    in
    {
      preInstall = (old.preInstall or "") + ''
        cp -r ${mt7916TestFirmware}/* mediatek/
      '';
      outputHash = null;
      outputHashAlgo = null;
      outputHashMode = null;
    });
}
