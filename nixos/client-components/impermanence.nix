{ config, pkgs, ... }:

{
  environment.persistence."/nix/persistent" = {
    directories = [
      "/home/lantian"
    ];
  };
}
