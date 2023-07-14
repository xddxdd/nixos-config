{
  config,
  lib,
  ...
}: {
  imports = [
    ./uptimerobot.nix
  ];

  variable = {
    "email" = {
      description = "Admin Email";
      type = "string";
      sensitive = false;
    };
  };
}
