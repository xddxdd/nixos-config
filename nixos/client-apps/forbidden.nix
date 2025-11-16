_:
{
  system.forbiddenDependenciesRegexes = [
    # Disallow compiling firefox/thunderbird ourselves
    "firefox-[0-9\\.]+$"
    "librewolf-[0-9\\.]+$"
    "thunderbird-[0-9\\.]+$"
  ];
}
