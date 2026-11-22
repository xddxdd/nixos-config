{
  config,
  LT,
  lib,
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
{
  systemd.services.pi-web = {
    description = "Pi Web";
    after = [ "network.target" ];
    environment = {
      PATH = lib.mkForce "/run/current-system/sw/bin:/etc/profiles/per-user/lantian/bin";
      PORT = LT.portStr.PiWeb;
      PI_WEB_HOSTNAME = "127.0.0.1";
      PI_WEB_NO_OPEN = "1";
      PI_WEB_ALLOWED_HOSTS = "pi.localhost";
    }
    //
      lib.optionalAttrs
        (config.programs.gnupg.agent.enable && config.programs.gnupg.agent.enableSSHSupport)
        {
          SSH_AUTH_SOCK = "/run/user/${toString config.users.users.lantian.uid}/gnupg/S.gpg-agent.ssh";
        };
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "lantian";
      ExecStart = lib.getExe pi-web;
      Restart = "always";
      RestartSec = "5";
    };
  };

  lantian.localVhosts.pi = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.PiWeb}";
        proxyWebsockets = true;
        proxyOverrideHost = "pi.localhost";
        proxyOverrideOrigin = "https://pi.localhost";
        proxyNoTimeout = true;
      };
    };
  };
}
