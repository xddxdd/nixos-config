{
  pkgs,
  lib,
  config,
  LT,
  ...
}:
let
  # https://lobehub.com/zh/icons
  # https://github.com/lobehub/lobe-icons/tree/master/packages/static-png/dark
  modelIconMapping = {
    "01-ai/yi" = "yi-color.png";
    "360ai/" = "ai360-color.png";
    "ai21/" = "ai21.png";
    "aion-labs/" = "aionlabs-color.png";
    "amazon/" = "aws-color.png";
    "anthropic/claude" = "claude-color.png";
    "baai/" = "baai.png";
    "baichuan/" = "baichuan-color.png";
    "baidu/" = "baidu-color.png";
    "black-forest-labs/" = "flux.png";
    "bytedance" = "bytedance-color.png";
    "cohere/" = "cohere-color.png";
    "deepseek/" = "deepseek-color.png";
    "fishaudio/" = "fishaudio.png";
    "google/" = "gemini-color.png";
    "google/gemini" = "gemini-color.png";
    "google/gemma" = "gemma-color.png";
    "infermatic/" = "infermatic-color.png";
    "inflection/" = "inflection.png";
    "internlm/" = "internlm-color.png";
    "meta-llama/" = "meta-color.png";
    "microsoft/" = "microsoft-color.png";
    "minimax/" = "minimax-color.png";
    "mistralai/" = "mistral-color.png";
    "moonshotai/" = "moonshot.png";
    "nousresearch/" = "nousresearch.png";
    "nvidia/" = "nvidia-color.png";
    "openai/" = "openai.png";
    "openchat/" = "openchat-color.png";
    "openrouter/" = "openrouter.png";
    "perplexity/" = "perplexity-color.png";
    "qwen/" = "qwen-color.png";
    "stabilityai/" = "stability-color.png";
    "tencent/" = "tencent-color.png";
    "thudm/" = "chatglm-color.png";
    "tiiuae/" = "tii-color.png";
    "x-ai/grok" = "grok.png";
  };
  defaultModelIcon = "/static/favicon.png";

  lookupModelIconUrl =
    name:
    builtins.foldl'
      (
        current: mapping:
        if lib.hasPrefix mapping.name name then "/model-icons/${mapping.value}" else current
      )
      defaultModelIcon
      (
        lib.sort (a: b: builtins.stringLength a.name < builtins.stringLength b.name) (
          lib.attrsToList modelIconMapping
        )
      );

  mkSQLForModel =
    name:
    let
      iconUrl = lookupModelIconUrl name;
    in
    ''
      INSERT INTO model (id, user_id, base_model_id, "name", meta, params, created_at, updated_at, access_control, is_active)
      VALUES (
        '${name}',
        '$ADMIN_ID',
        NULL,
        '${name}',
        '{"profile_image_url": "${iconUrl}", "description": null, "capabilities": {"vision": true, "citations": true}, "suggestion_prompts": null, "tags": []}',
        '{"function_calling": "native"}',
        $TIMESTAMP,
        $TIMESTAMP,
        '{"read": {"group_ids": [], "user_ids": []}, "write": {"group_ids": [], "user_ids": []}}',
        TRUE
      );
    '';

  models = lib.unique (
    lib.flatten (
      builtins.map (provider: builtins.map (v: v.value) provider._models) config.lantian.llm-providers
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
