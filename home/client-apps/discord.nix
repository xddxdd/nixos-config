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
    discord = {
      enable = true;
      vencord.enable = true;
      openASAR.enable = true;
    };
    vesktop.enable = true;

    # Plugins
    config = {
      plugins = {
        alwaysAnimate.enable = true;
        alwaysTrust.enable = true;
        clearUrLs.enable = true;
        copyFileContents.enable = true;
        copyUserUrLs.enable = true;
        disableCallIdle.enable = true;
        favoriteEmojiFirst.enable = true;
        forceOwnerCrown.enable = true;
        friendsSince.enable = true;
        noDevtoolsWarning.enable = true;
        readAllNotificationsButton.enable = true;
        serverInfo.enable = true;
        silentMessageToggle.enable = true;
        silentTyping.enable = true;
        startupTimings.enable = true;
        validReply.enable = true;
        validUser.enable = true;
      };
    };
  };
}
