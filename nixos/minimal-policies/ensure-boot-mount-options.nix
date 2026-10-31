{ config, lib, ... }:
{
  assertions = [
    {
      assertion =
        !(config.fileSystems ? "/boot")
        || builtins.elem "bind" config.fileSystems."/boot".options
        || lib.all (option: builtins.elem option config.fileSystems."/boot".options) (
          [
            "nosuid"
            "nodev"
            "noexec"
          ]
          ++ lib.optionals (config.fileSystems."/boot".fsType == "vfat") [
            "fmask=0077"
            "dmask=0077"
          ]
        );
      message = "fileSystems.\"/boot\" must be a bind mount or include nosuid, nodev and noexec in its options, plus fmask=0077 and dmask=0077 for vfat";
    }
  ];
}
