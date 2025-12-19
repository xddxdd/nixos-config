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
in
{
  imports = [ ./postgresql.nix ];

  age.secrets.attic-upload-key = {
    file = inputs.secrets + "/attic-upload-key.age";
    mode = "0444";
  };

  environment.etc."hydra/attic-upload".source = pkgs.writeShellScript "attic-upload" ''
    ${pkgs.attic-client}/bin/attic push lantian \
      $(cat "$HYDRA_JSON" | ${pkgs.jq}/bin/jq -r ".outputs[].path")
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
        command = /etc/hydra/attic-upload
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
