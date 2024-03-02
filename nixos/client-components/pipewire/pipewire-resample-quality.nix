{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  services.pipewire.configPackages =
    builtins.map
    (n:
      pkgs.writeTextFile {
        name = "pipewire-${n}-resample-quality";
        text = builtins.toJSON {
          "stream.properties"."resample.quality" = 10;
        };
        destination = "/share/pipewire/${n}.conf.d/resample-quality.conf";
      })
    [
      "client-rt"
      "client"
      "jack"
      "pipewire-pulse"
    ];
}
