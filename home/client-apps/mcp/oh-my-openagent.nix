{ pkgs, ... }:
{
  home.packages = [
    pkgs.llm-agents.oh-my-opencode
  ];

  xdg.configFile."opencode/oh-my-openagent.json".text = builtins.toJSON {
    "$schema" =
      "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";
    agents = {
      sisyphus = {
        model = "ollama-cloud/glm-5.1";
        variant = "max";
      };
      oracle = {
        model = "ollama-cloud/glm-5.1";
        variant = "max";
      };
      explore = {
        model = "ollama-cloud/glm-5.1";
      };
      multimodal-looker = {
        model = "ollama-cloud/kimi-k2.6";
      };
      prometheus = {
        model = "ollama-cloud/glm-5.1";
        variant = "max";
      };
      metis = {
        model = "ollama-cloud/glm-5.1";
        variant = "max";
      };
      momus = {
        model = "ollama-cloud/glm-5.1";
        variant = "max";
      };
      atlas = {
        model = "ollama-cloud/glm-5.1";
      };
      sisyphus-junior = {
        model = "ollama-cloud/glm-5.1";
      };
      librarian = {
        model = "ollama-cloud/glm-5.1";
      };
    };
    categories = {
      visual-engineering = {
        model = "ollama-cloud/glm-5.1";
        variant = "max";
      };
      ultrabrain = {
        model = "ollama-cloud/glm-5.1";
        variant = "max";
      };
      deep = {
        model = "ollama-cloud/glm-5.1";
        variant = "max";
      };
      quick = {
        model = "ollama-cloud/glm-5.1";
      };
      unspecified-low = {
        model = "ollama-cloud/glm-5.1";
      };
      unspecified-high = {
        model = "ollama-cloud/glm-5.1";
      };
      writing = {
        model = "ollama-cloud/glm-5.1";
      };
    };
  };
}
