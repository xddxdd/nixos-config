{
  LT,
  pkgs,
  config,
  inputs,
  ...
}:
let
  atticUploadScript = pkgs.writeShellScript "attic-upload" ''
    ${pkgs.attic-client}/bin/attic push lantian \
      $(cat "$HYDRA_JSON" | ${pkgs.jq}/bin/jq -r ".outputs[].path")
  '';
in
{
  imports = [ ./postgresql.nix ];

  age.secrets.attic-upload-key = {
    file = inputs.secrets + "/attic-upload-key.age";
    mode = "0444";
  };

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.lantian.pub";
    listenHost = LT.this.ltnet.IPv4;
    notificationSender = "postmaster@lantian.pub";
    port = LT.port.Hydra;

    extraConfig = ''
      <runcommand>
        job = *:*:*
        command = ${atticUploadScript}
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
