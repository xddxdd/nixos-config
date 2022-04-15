{ inputs, nixpkgs, ... }:

let
  awkFormatNginx = builtins.toFile "awkFormat-nginx.awk" ''
    awk -f
    {sub(/^[ \t]+/,"");idx=0}
    /\{/{ctx++;idx=1}
    /\}/{ctx--}
    {id="";for(i=idx;i<ctx;i++)id=sprintf("%s%s", id, "\t");printf "%s%s\n", id, $0}
  '';
in
final: prev: rec {
  writers = prev.writers // {
    writeNginxConfig = name: text: final.runCommandLocal name
      {
        inherit text;
        passAsFile = [ "text" ];
        nativeBuildInputs = with final; [ gawk gnused ];
      } ''
      awk -f ${awkFormatNginx} "$textPath" | sed '/^\s*$/d' > $out
    '';
  };
}
