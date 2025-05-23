{
  inputs,
  config,
  ...
}:
{
  age.secrets.btrbk-privkey = {
    file = inputs.secrets + "/btrbk-privkey.age";
    owner = "btrbk";
    group = "btrbk";
  };

  systemd.tmpfiles.rules = [ "d /mnt/root/.btrbk 700 btrbk btrbk" ];
  services.btrbk = {
    ioSchedulingClass = "idle";
    instances.btrbk = {
      onCalendar = "daily";
      settings = {
        group = config.networking.hostName;
        snapshot_preserve = "30d";
        snapshot_preserve_min = "7d";
        snapshot_dir = "/mnt/root/.btrbk";
        ssh_identity = config.age.secrets.btrbk-privkey.path;
        ssh_user = "btrbk";
        stream_compress = "zstd";
        stream_compress_level = "3";
        stream_compress_threads = "0";
        target = "ssh://lt-home-vm.lantian.pub/mnt/storage/backups/btrbk";
        volume = {
          "/mnt/root" = {
            subvolume = {
              home = {
                snapshot_create = "always";
              };
              persistent = {
                snapshot_create = "always";
              };
            };
          };
        };
      };
    };
  };

  users.users.btrbk.extraGroups = [ "wheel" ];
}
