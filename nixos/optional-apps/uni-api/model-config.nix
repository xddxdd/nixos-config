{
  LT,
  lib,
  config,
  inputs,
  ...
}:
let
  osConfig = config;

  providerTags = {
    # Base priorities
    free = 10;
    free_third_party = 20;
    free_unreliable = 30;
    paid = 40;

    # Modifiers
    slow = 1;
    context_limit = 1;
  };

  modelOptions =
    { config, ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
        };
        baseURL = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
        };
        engine = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        apiKeyPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = osConfig.age.secrets."uni-api-${config.name}-api-key".path;
        };
        cloudflareAccountIdPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        providerTags = lib.mkOption {
          type = lib.types.listOf (lib.types.enum (builtins.attrNames providerTags));
        };
        modelJsonFile = lib.mkOption {
          type = lib.types.path;
          default = inputs.secrets + "/uni-api/apis/${config.name}.json";
        };

        _models = lib.mkOption {
          readOnly = true;
          default = lib.flatten (
            lib.mapAttrsToList (
              k: v:
              let
                modelNameWithSuffix =
                  if lib.hasInfix ":" v then
                    lib.replaceStrings [ ":" ] [ ":${config.name}-" ] v
                  else
                    "${v}:${config.name}";
                isGeminiConversationModel =
                  config.engine == "gemini" && lib.hasPrefix "gemini" k && !lib.hasInfix "embed" k;
                modelNameWithSearchSuffix = "${modelNameWithSuffix}-search";
              in
              [
                (lib.nameValuePair k modelNameWithSuffix)
              ]
              ++ lib.optionals isGeminiConversationModel [
                (lib.nameValuePair k modelNameWithSearchSuffix)
              ]
            ) (lib.importJSON config.modelJsonFile)
          );
        };
        _score = lib.mkOption {
          readOnly = true;
          default = LT.math.sum (builtins.map (n: providerTags."${n}") config.providerTags);
        };
      };
    };
in
{
  imports = [
    (inputs.secrets + "/uni-api")
  ];

  options.lantian.llm-providers = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule modelOptions);
    default = [ ];
  };
}
