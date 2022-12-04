{ pkgs, lib, config, utils, inputs, ... }@args:

{
  boot.initrd.availableKernelModules = [
    "ahci"
    "sd_mod"

    # Support USB keyboards, in case the boot fails and we only have
    # a USB keyboard, or for LUKS passphrase prompt.
    "uhci_hcd"
    "ehci_hcd"
    "ehci_pci"
    "ohci_hcd"
    "ohci_pci"
    "xhci_hcd"
    "xhci_pci"
    "usbhid"
    "hid_generic"
    "usb_storage"
  ] ++ lib.optionals (pkgs.stdenv.isi686 || pkgs.stdenv.isx86_64) [
    # Misc. x86 keyboard stuff.
    "pcips2"
    "atkbd"
    "i8042"

    # x86 RTC needed by the stage 2 init script.
    "rtc_cmos"
  ];
}
