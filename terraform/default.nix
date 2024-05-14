{ ... }:
{
  imports = [
    ./remote-state.nix
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
