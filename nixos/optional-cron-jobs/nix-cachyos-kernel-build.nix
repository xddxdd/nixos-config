{
  pkgs,
  inputs,
  config,
  ...
}:
{
  age.secrets.attic-upload-key.file = inputs.secrets + "/attic-upload-key.age";

  systemd.services.nix-cachyos-kernel-build = {
    path = [
      pkgs.attic-client
      pkgs.nix-fast-build
    ];

    environment.HOME = "/var/cache/nix-cachyos-kernel-build";

    script = ''
      rm -f result*
      attic login --set-default lantian https://attic.colocrossing.xuyh0120.win $(cat ${config.age.secrets.attic-upload-key.path})
      nix-fast-build -f github:xddxdd/nix-cachyos-kernel#packages.x86_64-linux --skip-cached --no-nom -j$(nproc) || true
      attic push lantian result*
    '';

    serviceConfig = {
      Type = "oneshot";
      CacheDirectory = "nix-cachyos-kernel-build";
      WorkingDirectory = "/var/cache/nix-cachyos-kernel-build";
    };
  };

  systemd.timers.nix-cachyos-kernel-build = {
    wantedBy = [ "timers.target" ];
    partOf = [ "nix-cachyos-kernel-build.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      RandomizedDelaySec = "15m";
      Unit = "nix-cachyos-kernel-build.service";
    };
  };
}
