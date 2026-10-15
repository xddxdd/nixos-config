{
  LT,
  ...
}:
{
  lantian.nginxVhosts = {
    "ollama-cpa-honeypot-ollama" = {
      listenHTTPS.enable = false;
      listenHTTP = {
        enable = true;
        port = LT.port.OllamaCpaHoneypot.OllamaListener;
        default = true;
      };
      enableCommonLocationOptions = false;
      enableCommonVhostOptions = false;

      locations."/" = {
        proxyPass = "http://${LT.hosts.colocrossing.ltnet.IPv4}:${LT.portStr.OllamaCpaHoneypot.Ollama}";
        proxyNoTimeout = true;
      };
    };
    "ollama-cpa-honeypot-cpa" = {
      listenHTTPS.enable = false;
      listenHTTP = {
        enable = true;
        port = LT.port.OllamaCpaHoneypot.CpaListener;
        default = true;
      };
      enableCommonLocationOptions = false;
      enableCommonVhostOptions = false;

      locations."/" = {
        proxyPass = "http://${LT.hosts.colocrossing.ltnet.IPv4}:${LT.portStr.OllamaCpaHoneypot.Cpa}";
        proxyNoTimeout = true;
      };
    };
  };
}
