{ inputs, ... }:

final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
in
rec {
  hostapd = prev.hostapd.overrideAttrs (old: {
    extraConfig = (old.extraConfig or "") + ''
      CONFIG_IEEE80211AX=y
    '';
  });
  linux-firmware = prev.linux-firmware.overrideAttrs (old: let
    srcBeforeMtkUpdate = final.fetchzip {
      url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/linux-firmware-20221109.tar.gz";
      hash = "sha256-77xRUo4g24j5rGWYzVn/DZ1rfY+Ks9cmZ/+GCHELP5E=";
    };
  in {
    preInstall = (old.preInstall or "") + ''
      cp -r ${srcBeforeMtkUpdate}/mediatek/mt7916* mediatek/
    '';
    outputHash = null;
    outputHashAlgo = null;
    outputHashMode = null;
  });
}
