{ LT, pkgs, ... }:
{
  imports = [ ./postgresql.nix ];

  environment.etc."hydra/machines".text = ''
    localhost ${pkgs.stdenv.hostPlatform.system} - 2 1 kvm,nixos-test,big-parallel,benchmark - -
  '';

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.lantian.pub";
    listenHost = LT.this.ltnet.IPv4;
    notificationSender = "postmaster@lantian.pub";
    port = LT.port.Hydra;
    buildMachinesFiles = [ "/etc/hydra/machines" ];
    useSubstitutes = true;
  };
}
