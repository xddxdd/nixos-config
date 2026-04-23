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
        model = "ollama-cloud/glm-5";
        variant = "max";
      };
      oracle = {
        model = "ollama-cloud/glm-5";
        variant = "max";
      };
      explore = {
        model = "ollama-cloud/glm-5";
      };
      multimodal-looker = {
        model = "ollama-cloud/kimi-k2.6";
      };
      prometheus = {
        model = "ollama-cloud/glm-5";
        variant = "max";
      };
      metis = {
        model = "ollama-cloud/glm-5";
        variant = "max";
      };
      momus = {
        model = "ollama-cloud/glm-5";
        variant = "max";
      };
      atlas = {
        model = "ollama-cloud/glm-5";
      };
      sisyphus-junior = {
        model = "ollama-cloud/glm-5";
      };
      librarian = {
        model = "ollama-cloud/glm-5";
      };
    };
    categories = {
      visual-engineering = {
        model = "ollama-cloud/glm-5";
        variant = "max";
      };
      ultrabrain = {
        model = "ollama-cloud/glm-5";
        variant = "max";
      };
      deep = {
        model = "ollama-cloud/glm-5";
        variant = "max";
      };
      quick = {
        model = "ollama-cloud/glm-5";
      };
      unspecified-low = {
        model = "ollama-cloud/glm-5";
      };
      unspecified-high = {
        model = "ollama-cloud/glm-5";
      };
      writing = {
        model = "ollama-cloud/glm-5";
      };
    };
  };
}
