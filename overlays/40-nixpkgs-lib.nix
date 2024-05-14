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
          # nginx-config-formatter has an error - https://github.com/1connect/nginx-config-formatter/issues/16
          awk -f ${prev.writers.awkFormatNginx} "$textPath" | sed '/^\s*$/d' > $out
        '';
  };
}
