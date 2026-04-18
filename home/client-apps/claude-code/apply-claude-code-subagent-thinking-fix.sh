#!/bin/bash
#
# Claude Code SubAgent Thinking Config Fix Script
#
# THE BUG:
# SubAgents spawned with a subagent_type always have their thinkingConfig
# hardcoded to { type: "disabled" }. This means:
#   - Haiku SubAgents never send thinking: { type: "enabled", budget_tokens: N }
#   - Opus 4.7 [1M] SubAgents never send thinking: { type: "adaptive" }
# Some providers require the thinking field to be present for correct operation.
#
# ROOT CAUSE:
# In the SubAgent launcher function (_u / async function*), the options object
# is constructed with:
#   thinkingConfig: D ? _.options.thinkingConfig : { type: "disabled" }
# where D = useExactTools, which is only true for Fork agents (no subagent_type).
# All typed SubAgents get D=false, forcing thinkingConfig to disabled.
#
# THE FIX:
# Remove the conditional — always inherit thinkingConfig from the parent:
#   thinkingConfig: _.options.thinkingConfig
# The downstream API layer (s85 → k6) already applies per-model logic:
#   - kh8() → adaptive for opus-4-6/4-7/sonnet-4-6
#   - Fallback → enabled + budget_tokens for haiku/older models
#   - kM4() → disabled for claude-3-*
# So inheriting the parent config is safe; the API layer normalizes it.
#
# DETECTION STRATEGY (pure AST):
# 1. Find all Property nodes with key "thinkingConfig" whose value is
#    a ConditionalExpression with alternate = ObjectExpression containing
#    Property(key="type", value="disabled")
# 2. Cross-validate: the parent ObjectExpression must also contain a
#    Property with key "appendSubagentSystemPrompt" (unique to the
#    SubAgent launcher)
# 3. Replace the ConditionalExpression with only its consequent
#    (the inherited thinkingConfig path)
#
# COMPATIBILITY:
# Tested on v2.1.112+. Versions below 2.1.112 lack the
# appendSubagentSystemPrompt property used for cross-validation
# and are not supported by this script.
#
# Usage:
#   ./apply-claude-code-subagent-thinking-fix.sh                    # Apply fix
#   ./apply-claude-code-subagent-thinking-fix.sh /path/to/cli.js    # Specific file
#   ./apply-claude-code-subagent-thinking-fix.sh --check            # Check only
#   ./apply-claude-code-subagent-thinking-fix.sh --restore          # Restore backup
#

set -e

BACKUP_SUFFIX="backup-subagent-thinking"
FIX_DESCRIPTION="Force SubAgents to inherit parent thinkingConfig instead of disabled"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

success() { echo -e "${GREEN}[OK]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[X]${NC} $1"; }
info() { echo -e "${BLUE}[>]${NC} $1"; }

CHECK_ONLY=false
RESTORE=false
CLI_PATH_ARG=""

while [[ $# -gt 0 ]]; do
  case $1 in
  --check | -c)
    CHECK_ONLY=true
    shift
    ;;
  --restore | -r)
    RESTORE=true
    shift
    ;;
  --help | -h)
    echo "Usage: $0 [options] [cli.js path]"
    echo ""
    echo "$FIX_DESCRIPTION"
    echo ""
    echo "Arguments:"
    echo "  cli.js path    Path to cli.js file (optional, auto-detect if not provided)"
    echo ""
    echo "Options:"
    echo "  --check, -c    Check if fix is needed without making changes"
    echo "  --restore, -r  Restore original file from backup"
    echo "  --help, -h     Show help information"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Auto-detect and apply fix"
    echo "  $0 /path/to/cli.js                    # Apply fix to specific file"
    echo "  $0 --check /path/to/cli.js            # Check specific file"
    exit 0
    ;;
  -*)
    error "Unknown option: $1"
    exit 1
    ;;
  *)
    if [[ -z $CLI_PATH_ARG ]]; then
      CLI_PATH_ARG="$1"
    else
      error "Unexpected argument: $1"
      exit 1
    fi
    shift
    ;;
  esac
done

find_cli_path() {
  local locations=(
    "$HOME/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js"
    "/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js"
    "/usr/lib/node_modules/@anthropic-ai/claude-code/cli.js"
  )
  if command -v npm &>/dev/null; then
    local npm_root
    npm_root=$(npm root -g 2>/dev/null || true)
    if [[ -n $npm_root ]]; then
      locations+=("$npm_root/@anthropic-ai/claude-code/cli.js")
    fi
  fi
  for path in "${locations[@]}"; do
    if [[ -f $path ]]; then
      echo "$path"
      return 0
    fi
  done
  return 1
}

if [[ -n $CLI_PATH_ARG ]]; then
  if [[ -f $CLI_PATH_ARG ]]; then
    CLI_PATH="$CLI_PATH_ARG"
    info "Using specified cli.js: $CLI_PATH"
  else
    error "Specified file not found: $CLI_PATH_ARG"
    exit 1
  fi
else
  CLI_PATH=$(find_cli_path) || {
    error "Claude Code cli.js not found"
    echo ""
    echo "Searched locations:"
    echo "  ~/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js"
    echo "  /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js"
    echo '  $(npm root -g)/@anthropic-ai/claude-code/cli.js'
    echo ""
    echo "Tip: You can specify the path directly:"
    echo "  $0 /path/to/cli.js"
    exit 1
  }
  info "Found Claude Code: $CLI_PATH"
fi

CLI_DIR=$(dirname "$CLI_PATH")

if $RESTORE; then
  LATEST_BACKUP=$(ls -t "$CLI_DIR"/cli.js.${BACKUP_SUFFIX}-* 2>/dev/null | head -1)
  if [[ -n $LATEST_BACKUP ]]; then
    cp "$LATEST_BACKUP" "$CLI_PATH"
    success "Restored from backup: $LATEST_BACKUP"
    exit 0
  else
    error "No backup file found (cli.js.${BACKUP_SUFFIX}-*)"
    exit 1
  fi
fi

echo ""

# Download acorn parser if needed
ACORN_PATH="/tmp/acorn-claude-fix.js"
if [[ ! -f $ACORN_PATH ]]; then
  info "Downloading acorn parser..."
  curl -sL "https://unpkg.com/acorn@8.14.0/dist/acorn.js" -o "$ACORN_PATH" || {
    error "Failed to download acorn parser"
    exit 1
  }
fi

# Create AST patch script
PATCH_SCRIPT=$(mktemp)
cat >"$PATCH_SCRIPT" <<'PATCH_EOF'
const fs = require('fs');
const acorn = require(process.argv[2]);

const cliPath = process.argv[3];
const checkOnly = process.argv[4] === '--check';
const backupSuffix = process.env.BACKUP_SUFFIX || 'backup-subagent-thinking';

let code = fs.readFileSync(cliPath, 'utf-8');

let shebang = '';
if (code.startsWith('#!')) {
    const idx = code.indexOf('\n');
    shebang = code.slice(0, idx + 1);
    code = code.slice(idx + 1);
}

// ============================================================
// Parse AST
// ============================================================

let ast;
try {
    ast = acorn.parse(code, { ecmaVersion: 2022, sourceType: 'module' });
} catch (e) {
    console.error('PARSE_ERROR:' + e.message);
    process.exit(1);
}

const src = (node) => code.slice(node.start, node.end);

// ============================================================
// AST walker with parent tracking
// ============================================================

function walkWithParent(node, callback, parent = null, parentPropKey = null) {
    if (!node || typeof node !== 'object') return;
    callback(node, parent, parentPropKey);
    for (const key of Object.keys(node)) {
        const child = node[key];
        if (child && typeof child === 'object') {
            if (Array.isArray(child)) {
                for (const item of child) {
                    if (item && typeof item.type === 'string') {
                        walkWithParent(item, callback, node, key);
                    }
                }
            } else if (typeof child.type === 'string') {
                walkWithParent(child, callback, node, key);
            }
        }
    }
}

// ============================================================
// Step 1: Find all Property nodes where:
//   - key.name === "thinkingConfig" (or key.value === "thinkingConfig")
//   - value is a ConditionalExpression
//   - ConditionalExpression.alternate is ObjectExpression
//   - That ObjectExpression contains Property(key="type", value="disabled")
// ============================================================

const thinkingConfigProps = [];

walkWithParent(ast, (node, parent) => {
    if (node.type !== 'Property') return;

    // Check key is "thinkingConfig"
    const keyName = node.key.type === 'Identifier' ? node.key.name :
                    node.key.type === 'Literal' ? node.key.value : null;
    if (keyName !== 'thinkingConfig') return;

    // Value must be ConditionalExpression
    if (!node.value || node.value.type !== 'ConditionalExpression') return;

    const cond = node.value;

    // Alternate must be ObjectExpression with { type: "disabled" }
    if (!cond.alternate || cond.alternate.type !== 'ObjectExpression') return;

    const altProps = cond.alternate.properties;
    const hasTypeDisabled = altProps.some(p => {
        const pKey = p.key.type === 'Identifier' ? p.key.name :
                     p.key.type === 'Literal' ? p.key.value : null;
        return pKey === 'type' &&
               p.value.type === 'Literal' &&
               p.value.value === 'disabled';
    });
    if (!hasTypeDisabled) return;

    thinkingConfigProps.push({ prop: node, cond, parent });
});

if (thinkingConfigProps.length === 0) {
    // Check if already patched: thinkingConfig property with MemberExpression value
    let foundPatched = false;
    walkWithParent(ast, (node) => {
        if (node.type !== 'Property') return;
        const keyName = node.key.type === 'Identifier' ? node.key.name :
                        node.key.type === 'Literal' ? node.key.value : null;
        if (keyName !== 'thinkingConfig') return;
        // Patched form: thinkingConfig: _.options.thinkingConfig (MemberExpression)
        if (node.value && node.value.type === 'MemberExpression') {
            const valSrc = src(node.value);
            if (valSrc.includes('.options.thinkingConfig')) {
                foundPatched = true;
            }
        }
    });
    if (foundPatched) {
        console.log('ALREADY_PATCHED');
        process.exit(2);
    }
    console.error('NOT_FOUND:No thinkingConfig ConditionalExpression with {type:"disabled"} alternate found');
    process.exit(1);
}

console.log('FOUND:' + thinkingConfigProps.length + ' thinkingConfig conditional(s) with {type:"disabled"} alternate');

// ============================================================
// Step 2: Cross-validate — the parent ObjectExpression must also
//         contain "appendSubagentSystemPrompt" property.
//         This uniquely identifies the SubAgent launcher.
// ============================================================

let target = null;

for (const candidate of thinkingConfigProps) {
    // Walk up: the Property is inside an ObjectExpression
    // We need to find the ObjectExpression that contains this Property
    // and check for "appendSubagentSystemPrompt" sibling

    // Since we have parent tracking, check if parent is ObjectExpression
    // Actually the Property is a direct child of ObjectExpression.properties
    // We need to find the ObjectExpression that owns this property.

    // Re-walk to find the containing ObjectExpression
    let containingObj = null;
    walkWithParent(ast, (node) => {
        if (node.type !== 'ObjectExpression') return;
        if (!node.properties) return;
        for (const p of node.properties) {
            if (p === candidate.prop) {
                containingObj = node;
                return;
            }
        }
    });

    if (!containingObj) continue;

    // Check for "appendSubagentSystemPrompt" sibling property
    const hasSubagentProp = containingObj.properties.some(p => {
        if (p.type === 'SpreadElement') return false;
        const pKey = p.key?.type === 'Identifier' ? p.key.name :
                     p.key?.type === 'Literal' ? p.key.value : null;
        return pKey === 'appendSubagentSystemPrompt';
    });

    if (!hasSubagentProp) {
        console.log('FOUND:  skipping candidate at offset ' + candidate.prop.start + ' (no appendSubagentSystemPrompt sibling)');
        continue;
    }

    // Double-check: also verify "mainLoopModel" sibling exists
    const hasMainLoopModel = containingObj.properties.some(p => {
        if (p.type === 'SpreadElement') return false;
        const pKey = p.key?.type === 'Identifier' ? p.key.name :
                     p.key?.type === 'Literal' ? p.key.value : null;
        return pKey === 'mainLoopModel';
    });

    if (!hasMainLoopModel) {
        console.log('FOUND:  skipping candidate at offset ' + candidate.prop.start + ' (no mainLoopModel sibling)');
        continue;
    }

    target = candidate;
    break;
}

if (!target) {
    // No candidate passed cross-validation — check if already patched
    let foundPatched = false;
    walkWithParent(ast, (node) => {
        if (node.type !== 'ObjectExpression' || !node.properties) return;
        const hasSubagent = node.properties.some(p => {
            if (p.type === 'SpreadElement') return false;
            const k = p.key?.type === 'Identifier' ? p.key.name : null;
            return k === 'appendSubagentSystemPrompt';
        });
        if (!hasSubagent) return;
        const thinkProp = node.properties.find(p => {
            if (p.type === 'SpreadElement') return false;
            const k = p.key?.type === 'Identifier' ? p.key.name : null;
            return k === 'thinkingConfig';
        });
        if (thinkProp && thinkProp.value && thinkProp.value.type === 'MemberExpression') {
            if (src(thinkProp.value).includes('.options.thinkingConfig')) {
                foundPatched = true;
            }
        }
    });
    if (foundPatched) {
        console.log('ALREADY_PATCHED');
        process.exit(2);
    }
    console.error('NOT_FOUND:No thinkingConfig conditional found in SubAgent launcher context (with appendSubagentSystemPrompt sibling)');
    process.exit(1);
}

const cond = target.cond;
const consequentSrc = src(cond.consequent);

console.log('FOUND:Target at offset ' + target.prop.start);
console.log('FOUND:  test     = ' + src(cond.test));
console.log('FOUND:  truthy   = ' + consequentSrc);
console.log('FOUND:  falsy    = ' + src(cond.alternate));

if (checkOnly) {
    console.log('NEEDS_PATCH');
    console.log('PATCH_COUNT:1');
    process.exit(1);
}

// ============================================================
// Step 3: Patch — replace the ConditionalExpression with just
//         the consequent (the inherited thinkingConfig path).
//
//   BEFORE: thinkingConfig: D ? _.options.thinkingConfig : {type:"disabled"}
//   AFTER:  thinkingConfig: _.options.thinkingConfig
// ============================================================

const newCode = code.slice(0, cond.start) + consequentSrc + code.slice(cond.end);

console.log('PATCH:thinkingConfig — removed conditional, now always inherits parent config');

// ============================================================
// Verify the patch didn't break AST parseability
// ============================================================

try {
    acorn.parse(newCode, { ecmaVersion: 2022, sourceType: 'module' });
} catch (e) {
    console.error('VERIFY_FAILED:Patched code fails to parse: ' + e.message);
    process.exit(1);
}

console.log('FOUND:Post-patch AST validation passed');

// ============================================================
// Backup and save
// ============================================================

const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
const backupPath = cliPath + '.' + backupSuffix + '-' + timestamp;
fs.copyFileSync(cliPath, backupPath);
console.log('BACKUP:' + backupPath);

fs.writeFileSync(cliPath, shebang + newCode);
console.log('SUCCESS:1');
PATCH_EOF

CHECK_ARG=""
if $CHECK_ONLY; then
  CHECK_ARG="--check"
fi

export BACKUP_SUFFIX
OUTPUT=$(node "$PATCH_SCRIPT" "$ACORN_PATH" "$CLI_PATH" "$CHECK_ARG" 2>&1) || true
EXIT_CODE=$?

rm -f "$PATCH_SCRIPT"

while IFS= read -r line; do
  case "$line" in
  ALREADY_PATCHED)
    success "Already patched (SubAgent thinking inheritance enabled)"
    exit 0
    ;;
  PARSE_ERROR:*)
    error "Failed to parse cli.js: ${line#PARSE_ERROR:}"
    exit 1
    ;;
  NOT_FOUND:*)
    error "${line#NOT_FOUND:}"
    exit 1
    ;;
  FOUND:*)
    info "${line#FOUND:}"
    ;;
  PATCH:*)
    info "Patch: ${line#PATCH:}"
    ;;
  NEEDS_PATCH)
    echo ""
    warning "Patch needed - run without --check to apply"
    ;;
  PATCH_COUNT:*)
    info "Need to patch ${line#PATCH_COUNT:} location(s)"
    exit 1
    ;;
  BACKUP:*)
    echo ""
    echo "Backup: ${line#BACKUP:}"
    ;;
  SUCCESS:*)
    echo ""
    success "Fix applied successfully!"
    echo ""
    echo "SubAgents will now inherit the parent's thinkingConfig."
    echo "Effect per model:"
    echo '  - Haiku 4.5:        thinking: { type: "enabled", budget_tokens: 31999 }'
    echo '  - Opus 4.6/4.7 1M:  thinking: { type: "adaptive" }'
    echo '  - Sonnet 4.6:       thinking: { type: "adaptive" }'
    echo ""
    warning "Restart Claude Code for changes to take effect"
    ;;
  VERIFY_FAILED:*)
    error "Verification failed: ${line#VERIFY_FAILED:}"
    exit 1
    ;;
  esac
done <<<"$OUTPUT"

exit $EXIT_CODE
