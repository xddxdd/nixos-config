{ LT, ... }:
{
  imports = [ ./postgresql.nix ];

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.lantian.pub";
    listenHost = LT.this.ltnet.IPv4;
    notificationSender = "postmaster@lantian.pub";
    port = LT.port.Hydra;
  };
}
