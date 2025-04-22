{
  pkgs,
  lib,
  config,
  ...
}:
let
  modelIconMapping = {
    "anthropic/claude" = "/model-icons/claude.webp";
    "deepseek/" = "/model-icons/deepseek.png";
    "google/gemini" = "/model-icons/gemini.png";
    "google/gemma" = "/model-icons/gemma.jpg";
    "openai/" = "/model-icons/gpt-35.webp";
    "x-ai/grok" = "/model-icons/grok.png";
    "meta-llama/" = "/model-icons/llama.png";
    "qwen/" = "/model-icons/qwen2.png";
  };
  defaultModelIcon = "/static/favicon.png";

  lookupModelIconUrl =
    name:
    builtins.foldl' (
      current: mapping: if lib.hasPrefix mapping.name name then mapping.value else current
    ) defaultModelIcon (lib.attrsToList modelIconMapping);

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

  modelsCfg = import ../uni-api/models.nix { inherit lib config; };
  models = lib.unique (
    lib.flatten (
      builtins.map (
        provider: builtins.map (model: builtins.head (builtins.attrValues model)) provider.model
      ) modelsCfg.providers
    )
  );

  sqlFile = pkgs.writeText "open-webui-setup.sql" (lib.concatMapStrings mkSQLForModel models);
in
{
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

      export ADMIN_ID=$(owsql -c 'SELECT id FROM public.user WHERE role = 'admin' ORDER BY created_at ASC LIMIT 1')
      echo "Admin ID: $ADMIN_ID"

      export TIMESTAMP=$(date "+%s")
      echo "Timestamp: $TIMESTAMP"

      cat ${sqlFile} | envsubst > setup.sql

      owsql -c 'DELETE FROM public.model WHERE base_model_id = NULL'
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
