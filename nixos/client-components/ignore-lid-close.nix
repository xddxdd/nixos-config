_: {
  # Disable suspend on lid close
  services.upower.ignoreLid = true;
  services.logind.settings.Login = {
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitch = "ignore";
  };
}
