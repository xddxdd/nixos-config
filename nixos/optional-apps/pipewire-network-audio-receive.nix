{ pkgs, LT, ... }:
{
  services.pipewire.configPackages = [
    (pkgs.writeTextFile {
      name = "pipewire-network-audio-receive";
      # Pipewire refuses to load zeroconf module if config is provided as JSON
      text = ''
        pulse.cmd = [
          { cmd = "load-module" args = "module-native-protocol-tcp" flags = ["port=${LT.portStr.Pipewire.TCP}" "listen=0.0.0.0" "auth-anonymous=true"] }
          { cmd = "load-module" args = "module-zeroconf-publish" }
        ]
      '';
      destination = "/share/pipewire/pipewire-pulse.conf.d/network-audio-receive.conf";
    })
  ];
}
