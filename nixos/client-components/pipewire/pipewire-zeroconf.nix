{ pkgs, ... }@args:
{
  services.pipewire.configPackages = [
    (pkgs.writeTextFile {
      name = "pipewire-zeroconf";
      text = builtins.toJSON {
        "context.modules" = [
          {
            name = "libpipewire-module-zeroconf-discover";
            args = { };
          }
        ];
      };
      destination = "/share/pipewire/pipewire.conf.d/zeroconf.conf";
    })
  ];
}
