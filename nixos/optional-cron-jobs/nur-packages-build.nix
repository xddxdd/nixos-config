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

    environment.HOME = "/var/cache/nur-packages-build";

    script = ''
      rm -f result*
      attic login --set-default lantian https://attic.colocrossing.xuyh0120.win $(cat ${config.age.secrets.attic-upload-key.path})
      nix-fast-build -f github:xddxdd/nur-packages#ciPackages.x86_64-linux --skip-cached --no-nom -j$(nproc) || true
      attic push lantian result*
    '';

    serviceConfig = {
      Type = "oneshot";
      CacheDirectory = "nur-packages-build";
      WorkingDirectory = "/var/cache/nur-packages-build";
    };
  };

  systemd.timers.nur-packages-build = {
    wantedBy = [ "timers.target" ];
    partOf = [ "nur-packages-build.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      RandomizedDelaySec = "15m";
      Unit = "nur-packages-build.service";
    };
  };
}
