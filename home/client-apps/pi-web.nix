{
  config,
  LT,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  pi-web = pkgs.nur-xddxdd.pi-web.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../patches/pi-web-raw-model-id.patch
      ../../patches/pi-web-disabled-packages.patch
    ];
  });
in
lib.mkIf (osConfig.networking.hostName == "lt-hp-omen" && config.home.username == "lantian") {
  systemd.user.services.pi-web = {
    Unit = {
      Description = "Pi Web";
      After = [ "network.target" ];
    };

    Service = {
      Environment =
        lib.optionals
          (osConfig.programs.gnupg.agent.enable && osConfig.programs.gnupg.agent.enableSSHSupport)
          [
            "SSH_AUTH_SOCK=%t/gnupg/S.gpg-agent.ssh"
          ]
        ++ [
          "PORT=${LT.portStr.PiWeb}"
          "PI_WEB_HOSTNAME=127.0.0.1"
          "PI_WEB_NO_OPEN=1"
          "PI_WEB_ALLOWED_HOSTS=pi.localhost"
        ];
      ExecStart = lib.getExe pi-web;
      Restart = "always";
      RestartSec = "5";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
