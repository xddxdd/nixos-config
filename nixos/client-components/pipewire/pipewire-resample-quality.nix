{ pkgs, ... }:
{
  services.pipewire.configPackages =
    builtins.map
      (
        n:
        pkgs.writeTextFile {
          name = "pipewire-${n}-resample-quality";
          text = builtins.toJSON {
            "context.properties"."default.clock.min-quantum" = 1024;
            "stream.properties"."resample.quality" = 10;
          };
          destination = "/share/pipewire/${n}.conf.d/resample-quality.conf";
        }
      )
      [
        "client-rt"
        "client"
        "jack"
        "pipewire-pulse"
      ];
}
