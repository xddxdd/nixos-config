_: final: prev: {
  writers = prev.writers // {
    writeNginxConfig =
      name: text:
      final.runCommandLocal name
        {
          inherit text;
          passAsFile = [ "text" ];
        }
        ''
          cp "$textPath" $out
          ${final.lib.getExe final.nginx-config-formatter} --max-empty-lines 0 $out
          ${final.lib.getExe final.gnused} -i 's/ ;/;/g' $out
        '';
  };
}
