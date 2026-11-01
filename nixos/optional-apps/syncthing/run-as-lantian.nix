{ lib, ... }: {
  imports = [ ./default.nix ];

  services.syncthing = {
    user = lib.mkForce "lantian";
    group = lib.mkForce "lantian";
  };
  lantian.syncthing.storage = "/home/lantian";
  systemd.services.syncthing.serviceConfig = {
    ProtectHome = false;
    BindPaths = [ "/home/lantian" ];
  };
}
