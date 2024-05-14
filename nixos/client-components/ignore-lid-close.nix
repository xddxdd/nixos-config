_: {
  # Disable suspend on lid close
  services.upower.ignoreLid = true;
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";
}
