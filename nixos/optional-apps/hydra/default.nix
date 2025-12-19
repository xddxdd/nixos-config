{
  LT,
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  platforms = builtins.concatStringsSep "," (
    lib.uniqueStrings (config.nix.settings.extra-platforms ++ [ pkgs.stdenv.hostPlatform.system ])
  );

  py = pkgs.python3.withPackages (
    ps: with ps; [
      pydantic
      requests
    ]
  );
  path = lib.makeBinPath [
    pkgs.git
    pkgs.jq
    pkgs.attic-client
  ];
in
{
  imports = [ ../postgresql.nix ];

  age.secrets.attic-upload-key = {
    file = inputs.secrets + "/attic-upload-key.age";
    mode = "0444";
  };

  environment.etc."hydra/post-build".source = pkgs.writeShellScript "post-build" ''
    export PATH="${path}:$PATH"
    export HYDRA_URL="http://${LT.this.ltnet.IPv4}:${LT.portStr.Hydra}"

    jq . "$HYDRA_JSON"
    exec ${py}/bin/python3 ${./post-build.py} "$HYDRA_JSON"
  '';
  environment.etc."hydra/machines".text = ''
    localhost ${platforms} - 2 1 kvm,nixos-test,big-parallel,benchmark - -
  '';

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.lantian.pub";
    listenHost = LT.this.ltnet.IPv4;
    notificationSender = "postmaster@lantian.pub";
    port = LT.port.Hydra;
    buildMachinesFiles = [ "/etc/hydra/machines" ];
    useSubstitutes = true;

    extraConfig = ''
      <runcommand>
        job = *:*:*
        command = /etc/hydra/post-build
      </runcommand>
    '';
  };

  systemd.services.hydra-notify = {
    preStart = ''
      if [ ! -f "$HOME/.config/attic/config.toml" ]; then
        ${pkgs.attic-client}/bin/attic login --set-default lantian \
          https://attic.colocrossing.xuyh0120.win \
          $(cat ${config.age.secrets.attic-upload-key.path})
      fi
    '';
  };
}
