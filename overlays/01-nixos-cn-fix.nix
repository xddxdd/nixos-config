{inputs, ...}: final: prev: rec {
  nixos-cn =
    prev.nixos-cn
    // {
      netease-cloud-music = prev.nixos-cn.netease-cloud-music.override {libusb = final.libusb1;};
    };
}
