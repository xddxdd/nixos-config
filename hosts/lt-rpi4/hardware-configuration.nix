{
  pkgs,
  lib,
  ...
}:
{
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.initrd.availableKernelModules = [
    "usbhid"
    "usb_storage"
    "vc4"
    "pcie_brcmstb" # required for the pcie bus to work
    "reset-raspberrypi" # required for vl805 firmware to load
  ];

  hardware.deviceTree.filter = lib.mkDefault "bcm2711-rpi-*.dtb";
  hardware.enableRedistributableFirmware = true;

  # Make RTL-SDR work with dump1090
  boot.extraModprobeConfig = ''
    blacklist dvb_usb_rtl28xxu
    install dvb_usb_rtl28xxu ${pkgs.coreutils}/bin/true
  '';

  environment.systemPackages = with pkgs; [
    i2c-tools
    libraspberrypi
    raspberrypi-eeprom
  ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/23df8a17-50e6-4262-b95d-ac4ab9bb90e4";
    fsType = "ext4";
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-uuid/2178-694E";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/29e85ee5-8c9f-469b-bdab-827b4ef64ae4";
    fsType = "btrfs";
    options = [
      "compress-force=zstd"
      "nosuid"
      "nodev"
    ];
  };

  # SPI support
  # https://github.com/ramonacat/monorepo/blob/8079b15d3c3be783399cc3263a026f0b6ba93286/machines/ananas/hardware.nix
  hardware.deviceTree = {
    enable = true;
    overlays = [
      {
        name = "spi0-0cs.dtbo";
        # this is from https://www.evolware.org/2021/02/21/using-spidev-with-mainline-linux-kernel-on-the-raspberry-pi-4/z, but with patched "compatible"
        dtsText = "
/dts-v1/;
/plugin/;

/{
        compatible = \"brcm,bcm2711\";
        fragment@0 {
                target-path = \"/soc/gpio@7e200000\";
                __overlay__ {
                        spi0_pins: spi0_pins {
                                brcm,pins = <0x09 0x0a 0x0b>;
                                brcm,function = <0x04>;
                                phandle = <0x0d>;
                        };

                        spi0_cs_pins: spi0_cs_pins {
                                brcm,pins = <0x08 0x07>;
                                brcm,function = <0x01>;
                                phandle = <0x0e>;
                        };
        };
    };
        fragment@1 {
                target-path = \"/soc/spi@7e204000\";
                __overlay__ {
             pinctrl-names = \"default\";
             pinctrl-0 = <&spi0_pins &spi0_cs_pins>;
             cs-gpios = <&gpio 8 1>, <&gpio 7 1>;
             status = \"okay\";

             spidev0: spidev@0{
                 compatible = \"lwn,bk4\";
                 reg = <0>;      /* CE0 */
                 #address-cells = <1>;
                 #size-cells = <0>;
                 spi-max-frequency = <125000000>;
             };

             spidev1: spidev@1{
                 compatible = \"lwn,bk4\";
                 reg = <1>;      /* CE1 */
                 #address-cells = <1>;
                 #size-cells = <0>;
                 spi-max-frequency = <125000000>;
             };
                };
        };
};
            ";
      }
    ];
  };

  users.groups.spi = { };
  users.groups.gpio = { };

  services.udev.extraRules = ''
      SUBSYSTEM=="spidev", KERNEL=="spidev0.0", GROUP="spi", MODE="0660"

    SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio",MODE="0660"
    SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio",MODE="0660", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio  /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
    SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add",RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
  '';
}
