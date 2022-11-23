{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../../helpers args;

  pythonPackages = python-packages: with python-packages; [
    telethon
  ];
  python = pkgs.python3.withPackages pythonPackages;
in
{
  age.secrets.tg-bot-cleaner-bot.file = inputs.secrets + "/tg-bot-cleaner-bot.age";

  systemd.services.tg-bot-cleaner-bot = {
    description = "A Bot that cleans other Telegram Bot messages";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = LT.serviceHarden // {
      EnvironmentFile = config.age.secrets.tg-bot-cleaner-bot.path;
      Restart = "always";
      RestartSec = "5s";
      WorkingDirectory = "/var/lib/tg-bot-cleaner-bot";
      StateDirectory = "tg-bot-cleaner-bot";
      User = "tg-bot-cleaner-bot";
      Group = "tg-bot-cleaner-bot";
    };
    script = ''
      exec ${python}/bin/python3 -u ${./script.py}
    '';
  };

  users.users.tg-bot-cleaner-bot = {
    group = "tg-bot-cleaner-bot";
    isSystemUser = true;
  };
  users.groups.tg-bot-cleaner-bot = { };
}
