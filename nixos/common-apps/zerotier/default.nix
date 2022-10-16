{ pkgs, lib, config, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };

  whitelistToBlacklist = wl: lib.splitString "\n" (builtins.readFile (pkgs.runCommandLocal "wl2bl.out" { } ''
    ${pkgs.python3Minimal}/bin/python3 ${./whitelist_to_blacklist.py} ${lib.escapeShellArgs wl} > $out
  ''));

  configFile = builtins.toJSON {
    settings = {
      interfacePrefixBlacklist = whitelistToBlacklist [
        "eth"
        "henet"
        "wlan"
      ];
      multipathMode = 2;
      softwareUpdate = "disable";
    };
  };
in
{
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "af78bf9436f191fd" ];
  };

  systemd.services.zerotierone = {
    preStart = ''
      mkdir -p /var/lib/zerotier-one
      cat ${pkgs.writeText "local.conf" configFile} > /var/lib/zerotier-one/local.conf
    '';
    restartIfChanged = false;
    serviceConfig.MemoryMax = "64M";
  };
}
