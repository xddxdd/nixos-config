{
  xdg.dataFile."reset-touchpad.sh" = {
    text = ''
      #!/bin/sh
      sudo modprobe -rv i2c_hid_acpi
      sleep 1
      sudo modprobe -v i2c_hid_acpi
      notify-send -i input-touchpad "Reset Touchpad" "Reset done!"
    '';
  };
}
