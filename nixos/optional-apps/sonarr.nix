{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ./qbittorrent.nix
  ];

  services.prowlarr.enable = true;
  systemd.services.prowlarr = {
    serviceConfig = LT.serviceHarden // {
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
      MemoryDenyWriteExecute = false;
      DynamicUser = lib.mkForce false;
      User = "lantian";
      Group = "users";
    };
  };

  services.sonarr = {
    enable = true;
    user = "lantian";
    group = "users";
    dataDir = "/var/lib/sonarr";
  };
  systemd.services.sonarr = {
    serviceConfig = LT.serviceHarden // {
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
      StateDirectory = "sonarr";
      MemoryDenyWriteExecute = false;
    };
  };
}
