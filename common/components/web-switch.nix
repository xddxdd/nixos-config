{ pkgs, config, options, ... }:

{
  options.lantian.enable-php = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = false;
    description = "Enable PHP-FPM for Nginx.";
  };
  options.lantian.enable-lab = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = false;
    description = "Enable lab.lantian.pub vhost.";
  };
}
