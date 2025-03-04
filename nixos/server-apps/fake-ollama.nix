{ pkgs, LT, ... }:
{

  systemd.services.fake-ollama = {
    description = "Fake Ollama";
    wantedBy = [ "multi-user.target" ];
    environment = {
      OLLAMA_HOST = "0.0.0.0:11434";
    };

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      ExecStart = "${pkgs.nur-xddxdd.fake-ollama}/bin/fake-ollama";
      Restart = "always";
      RestartSec = "3";

      User = "fake-ollama";
      Group = "fake-ollama";
    };
  };

  users.users.fake-ollama = {
    group = "fake-ollama";
    isSystemUser = true;
  };
  users.groups.fake-ollama = { };
}
