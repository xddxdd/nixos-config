{
  pkgs,
  lib,
  inputs,
}:
relativePath:
toString (
  pkgs.runCommand "secret-${lib.replaceStrings [ "/" ] [ "-" ] relativePath}"
    {
      # readFile drops the string context of inputs.secrets, otherwise the whole
      # secrets repository would become a dependency of the output
      passAsFile = [ "secretFile" ];
      secretFile = builtins.readFile (inputs.secrets + "/${relativePath}");
    }
    ''
      install -D -m 0444 "$secretFilePath" "$out"
    ''
)
