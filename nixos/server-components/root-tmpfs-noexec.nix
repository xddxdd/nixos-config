{ config, pkgs, lib, ... }:

{
  fileSystems."/".options = [ "noexec" ];
}
