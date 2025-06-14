{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [ inputs.nixcord.homeModules.nixcord ];

  programs.nixcord = lib.mkIf (config.home.username == "lantian") {
    enable = true;

    # Clients
    discord.enable = true;
    vesktop.enable = true;

    # Plugins
    openASAR.enable = true;
    config = {
      autoUpdate = true;
      plugins = {
        alwaysAnimate.enable = true;
        alwaysTrust.enable = true;
        clearURLs.enable = true;
        copyFileContents.enable = true;
        copyUserURLs.enable = true;
        disableCallIdle.enable = true;
        favoriteEmojiFirst.enable = true;
        forceOwnerCrown.enable = true;
        friendsSince.enable = true;
        noDevtoolsWarning.enable = true;
        readAllNotificationsButton.enable = true;
        serverInfo.enable = true;
        showMeYourName = {
          enable = true;
          mode = "nick-user";
        };
        silentMessageToggle.enable = true;
        silentTyping.enable = true;
        startupTimings.enable = true;
        validReply.enable = true;
        validUser.enable = true;
      };
    };
  };
}
