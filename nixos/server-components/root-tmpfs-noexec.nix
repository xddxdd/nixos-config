{ config, pkgs, ... }:

{
  fileSystems."/".options = [ "noexec" ];
}
