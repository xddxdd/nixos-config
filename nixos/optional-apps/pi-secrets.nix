{ LT, ... }:
{
  sops.secrets.pi-magic-context-openrouter-key = {
    sopsFile = LT.secret "pi.yaml";
    owner = "lantian";
    group = "lantian";
  };
}
