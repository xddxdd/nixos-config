{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  age.secrets.attic-upload-key.file = inputs.secrets + "/attic-upload-key.age";

  systemd.services.rebuild-nixos-config = {
    serviceConfig = LT.serviceHarden // {
      # Fix "GC Warning: Could not open /proc/stat"
      ProcSubset = "all";
      ProtectProc = "default";

      Type = "oneshot";
      RuntimeDirectory = "rebuild-nixos-config";
      WorkingDirectory = "/run/rebuild-nixos-config";
    };
    unitConfig.OnFailure = "notify-email-fail@%n.service";
    environment = {
      HOME = "/run/rebuild-nixos-config";
    };
    path = with pkgs; [
      colmena
      gitMinimal
      lantianCustomized.attic-telnyx-compatible
      nix
      nix-prefetch
      nix-prefetch-scripts
      nvfetcher
      openssh
    ];

    script = ''
      attic login --set-default lantian https://attic.xuyh0120.win "$(cat ${config.age.secrets.attic-upload-key.path})"
      git clone --depth 1 https://github.com/xddxdd/nixos-config.git nixos-config
      cd nixos-config
      nix run .#update
      nix run .#colmena -- build --on @x86_64-linux --verbose
      ls -alh .gcroots
      attic push lantian $(readlink -f .gcroots/*)
    '';
  };

  systemd.timers.rebuild-nixos-config = {
    wantedBy = [ "timers.target" ];
    partOf = [ "rebuild-nixos-config.service" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:00:00";
      RandomizedDelaySec = "1h";
      Unit = "rebuild-nixos-config.service";
    };
  };
}
