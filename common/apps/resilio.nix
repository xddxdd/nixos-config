{ pkgs, config, ... }:

{
  services.resilio = {
    enable = true;
    enableWebUI = true;
    deviceName = config.networking.hostName;
    httpListenPort = 13900;
  };
}
