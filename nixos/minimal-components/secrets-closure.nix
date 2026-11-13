{ inputs, ... }:
{
  # sops files are built by LT.secret and do not exist at evaluation time
  sops.validateSopsFiles = false;

  # the regex is interpolated into the system builder, so its string context
  # must be dropped or the system closure would contain this very path
  system.forbiddenDependenciesRegexes = [
    (builtins.unsafeDiscardStringContext inputs.secrets.outPath)
  ];
}
