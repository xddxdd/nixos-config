{ pkgs, ... }@args:
{
  services.pipewire.configPackages = [
    (pkgs.writeTextFile {
      name = "pipewire-airplay";
      text = builtins.toJSON {
        "context.modules" = [
          {
            name = "libpipewire-module-raop-discover";
            args = { };
          }
        ];
      };
      destination = "/share/pipewire/pipewire.conf.d/airplay.conf";
    })
  ];
}
