{ pkgs, lib, config, options, ... }:

{
  options.lantian.enable-php = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable PHP-FPM for Nginx.";
  };
}
