{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ./qbittorrent.nix
  ];

  services.jackett = {
    enable = true;
    user = "lantian";
    group = "users";
  };
  systemd.services.jackett = {
    serviceConfig = LT.serviceHarden // {
      StateDirectory = "jackett";
      MemoryDenyWriteExecute = false;
      ProcSubset = "all";
    };
  };

  services.sonarr = {
    enable = true;
    user = "lantian";
    group = "users";
  };
  systemd.services.sonarr = {
    serviceConfig = LT.serviceHarden // {
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
      StateDirectory = "sonarr";
      MemoryDenyWriteExecute = false;
    };
  };
}
