{
  LT,
  ...
}:
{
  lantian.localVhosts."sakura-llm" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.SakuraLLM}";
      proxyNoTimeout = true;
    };
  };
}
