{
  pkgs,
  ...
}:
let
  # Vendor list price per 1M tokens: input, output, cache read.
  rates = input: output: cacheRead: {
    inputCostPerToken = input / 1000000.0;
    outputCostPerToken = output / 1000000.0;
    cacheReadInputTokenCost = cacheRead / 1000000.0;
  };
in
{
  home.packages = [ pkgs.llm-agents.ccusage ];

  # https://ccusage.com/guide/config-files#configuration-file-locations
  # Aliases resolve to no usable LiteLLM entry, so they are priced by hand
  # against the underlying model's list price. DeepSeek rates are the peak
  # ones; off-peak is half.
  home.file.".config/claude/ccusage.json".text = builtins.toJSON {
    "$schema" = "https://ccusage.com/config-schema.json";
    defaults.pricingOverrides = {
      "deepseek-v4-flash:0731" = rates 0.14 0.28 0.0028; # DeepSeek V4 Flash 0731
      "lantian/coding-fast" = rates 0.3 1.2 0.006; # DeepSeek V4.1 Flash 1017
      "lantian/coding-smart" = rates 1.4 4.4 0.26; # GLM-5.3
      "minimax/minimax-m2.7:general-compute" = rates 0.3 1.2 0.06; # MiniMax-M2.7
      "moonshotai/kimi-k3:modal-kimi-k3" = rates 3 15 0.3; # Kimi K3
      "ollama-cloud/glm-5.3" = rates 1.4 4.4 0.26; # GLM-5.3
      "stealth/ox-alpha" = rates 0.15 0.5 0.03; # GLM-5.3-Flash
      "systalize/zai-org/GLM-5.3-Flash" = rates 0.15 0.5 0.03; # GLM-5.3-Flash
    };
  };
}
