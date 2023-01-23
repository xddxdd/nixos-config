{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  services.samba = {
    enable = true;
    enableNmbd = true;
    enableWinbindd = true;

    package = pkgs.samba4Full;
    nsswins = true;

    extraConfig =
      let
        ipv4Allow = lib.concatMapStringsSep " " (v: v) LT.constants.reserved.IPv4;
        ipv6Allow = lib.concatMapStringsSep " "
          (v:
            let
              splitted = lib.splitString "/" v;
            in
            "[${builtins.elemAt splitted 0}]/${builtins.elemAt splitted 1}")
          LT.constants.reserved.IPv6;
      in
      ''
        netbios name = ${config.networking.hostName}
        server string = ${config.networking.hostName}
        hosts allow = localhost ${ipv4Allow} ${ipv6Allow}
        hosts deny = 0.0.0.0/0 ::/0
        guest account = nobody
        map to guest = bad user
      '';
  };

  services.samba-wsdd = {
    enable = true;
  };
}
