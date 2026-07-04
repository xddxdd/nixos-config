{ LT, ... }:
{
  dialAntiFooling = ''
    #include ${LT.sources.anti-fooling-hot-line.src}/防忽悠咨询热线.conf
  '';

  dialAntiFoolingDescription = "Anti-fooling Hot Line (<a href=\"https://github.com/moontide/Anti-fooling-Hot-Line\" target=\"_blank\">https://github.com/moontide/Anti-fooling-Hot-Line</a>)";
}
