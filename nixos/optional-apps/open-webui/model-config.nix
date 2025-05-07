{
  pkgs,
  lib,
  config,
  ...
}:
let
  # https://lobehub.com/zh/icons
  modelIconMapping = {
    "01-ai/yi" = "/model-icons/yi-color.png";
    "360ai/" = "/model-icons/ai360-color.png";
    "ai21/" = "/model-icons/ai21.png";
    "aion-labs/" = "/model-icons/aionlabs-color.png";
    "amazon/" = "/model-icons/aws-color.png";
    "anthropic/claude" = "/model-icons/claude-color.png";
    "baai/" = "/model-icons/baai.png";
    "baichuan/" = "/model-icons/baichuan-color.png";
    "baidu/" = "/model-icons/baidu-color.png";
    "black-forest-labs/" = "/model-icons/flux.png";
    "bytedance" = "/model-icons/bytedance-color.png";
    "cohere/" = "/model-icons/cohere-color.png";
    "deepseek/" = "/model-icons/deepseek-color.png";
    "fishaudio/" = "/model-icons/fishaudio.png";
    "google/" = "/model-icons/gemini-color.png";
    "google/gemini" = "/model-icons/gemini-color.png";
    "google/gemma" = "/model-icons/gemma-color.png";
    "infermatic/" = "/model-icons/infermatic-color.png";
    "inflection/" = "/model-icons/inflection.png";
    "internlm/" = "/model-icons/internlm-color.png";
    "meta-llama/" = "/model-icons/meta-color.png";
    "microsoft/" = "/model-icons/microsoft-color.png";
    "minimax/" = "/model-icons/minimax-color.png";
    "mistralai/" = "/model-icons/mistral-color.png";
    "moonshotai/" = "/model-icons/moonshot.png";
    "nvidia/" = "/model-icons/nvidia-color.png";
    "openai/" = "/model-icons/openai.png";
    "openchat/" = "/model-icons/openchat-color.png";
    "openrouter/" = "/model-icons/openrouter.png";
    "perplexity/" = "/model-icons/perplexity-color.png";
    "qwen/" = "/model-icons/qwen-color.png";
    "stabilityai/" = "/model-icons/stability-color.png";
    "tencent/" = "/model-icons/tencent-color.png";
    "thudm/" = "/model-icons/chatglm-color.png";
    "tiiuae/" = "/model-icons/tii-color.png";
    "x-ai/grok" = "/model-icons/grok.png";
  };
  defaultModelIcon = "/static/favicon.png";

  lookupModelIconUrl =
    name:
    builtins.foldl'
      (current: mapping: if lib.hasPrefix mapping.name name then mapping.value else current)
      defaultModelIcon
      (
        lib.sort (a: b: builtins.stringLength a.name < builtins.stringLength b.name) (
          lib.attrsToList modelIconMapping
        )
      );

  nativeFunctionCallingPrefixes = [
    "anthropic/claude-3.5"
    "anthropic/claude-3.7"
    "deepseek/deepseek-v3-0324"
    "google/gemini-2.5"
    "openai/gpt-4o"
    "openai/o"
  ];

  hasNativeFunctionCalling =
    name: builtins.any (v: lib.hasPrefix v name) nativeFunctionCallingPrefixes;

  mkSQLForModel =
    name:
    let
      iconUrl = lookupModelIconUrl name;
      params = if hasNativeFunctionCalling name then ''{"function_calling": "native"}'' else "{}";
      shouldInclude = (lookupModelIconUrl name != defaultModelIcon) || (hasNativeFunctionCalling name);
    in
    if shouldInclude then
      ''
        INSERT INTO model (id, user_id, base_model_id, "name", meta, params, created_at, updated_at, access_control, is_active)
        VALUES (
          '${name}',
          '$ADMIN_ID',
          NULL,
          '${name}',
          '{"profile_image_url": "${iconUrl}", "description": null, "capabilities": {"vision": true, "citations": true}, "suggestion_prompts": null, "tags": []}',
          '${params}',
          $TIMESTAMP,
          $TIMESTAMP,
          '{"read": {"group_ids": [], "user_ids": []}, "write": {"group_ids": [], "user_ids": []}}',
          TRUE
        );
      ''
    else
      "";

  models = lib.unique (
    lib.flatten (
      builtins.map (provider: builtins.attrValues provider.models) config.lantian.llm-providers
    )
  );

  sqlFile = pkgs.writeText "open-webui-setup.sql" (lib.concatMapStrings mkSQLForModel models);
in
{
  imports = [ ../uni-api/models.nix ];

  systemd.services.open-webui-auto-setup = {
    description = "Auto set Open WebUI model configs";
    wantedBy = [ "multi-user.target" ];
    before = [ "open-webui.service" ];
    requiredBy = [ "open-webui.service" ];
    path = [
      pkgs.postgresql
      pkgs.envsubst
    ];
    script = ''
      set -euo pipefail

      owsql() {
        psql -qtAX -v ON_ERROR_STOP=1 -d open-webui "$@"
      }

      export ADMIN_ID=$(owsql -c "SELECT id FROM public.user WHERE role = 'admin' ORDER BY created_at ASC LIMIT 1")
      echo "Admin ID: $ADMIN_ID"

      export TIMESTAMP=$(date "+%s")
      echo "Timestamp: $TIMESTAMP"

      cat ${sqlFile} | envsubst > setup.sql

      owsql -c 'DELETE FROM public.model WHERE base_model_id IS NULL'
      owsql -f setup.sql
    '';

    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "5";

      RuntimeDirectory = "open-webui-auto-setup";
      WorkingDirectory = "/run/open-webui-auto-setup";

      User = "open-webui";
      Group = "open-webui";
    };
  };
}
