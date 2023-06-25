{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  age.secrets.attic-upload-key.file = inputs.secrets + "/attic-upload-key.age";

  systemd.services.rebuild-nixos-config = {
    serviceConfig =
      LT.serviceHarden
      // {
        Type = "oneshot";
        RuntimeDirectory = "rebuild-nixos-config";
        WorkingDirectory = "/run/rebuild-nixos-config";
      };
    unitConfig.OnFailure = "notify-email-fail@%n.service";
    environment = {
      HOME = "/run/rebuild-nixos-config";
    };
    path = with pkgs; [
      attic-client
      colmena
      git
      nix
    ];

    script = ''
      attic login --set-default lantian https://attic.xuyh0120.win "$(cat ${config.age.secrets.attic-upload-key.path})"
      git clone --depth 1 https://github.com/xddxdd/nixos-config.git nixos-config
      cd nixos-config
      nix run .#colmena -- build --verbose
      ls -alh .gcroots
      attic push lantian $(readlink -f .gcroots/*)
    '';
  };

  systemd.timers.rebuild-nixos-config = {
    wantedBy = ["timers.target"];
    partOf = ["rebuild-nixos-config.service"];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Unit = "rebuild-nixos-config.service";
    };
  };
}
