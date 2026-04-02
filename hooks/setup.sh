#!/usr/bin/env bash
set -euo pipefail

# JADE Setup Wizard
# Runs once on first session. Guard with ~/.claude/.jade-configured sentinel.

CONFIGURED_MARKER="$HOME/.claude/.jade-configured"

if [[ -f "$CONFIGURED_MARKER" ]]; then
  exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  JADE — First-Run Setup"
echo "  Jira → Approval → Driven Test → Evaluation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "JADE requires both Jira and GitHub to be configured before coding can begin."
echo ""

# ─────────────────────────────────────────────────
# Section A — Jira Setup
# ─────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📋 Jira Setup"
echo "  JADE syncs every task to a Jira ticket."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1 of 8 — Jira base URL
echo "Step 1 of 8 — Jira base URL"
echo "Example: https://yourcompany.atlassian.net"
printf "Jira URL: "
read -r JIRA_BASE_URL

# Strip trailing slash
JIRA_BASE_URL="${JIRA_BASE_URL%/}"

# Prepend https:// if missing
if [[ ! "$JIRA_BASE_URL" =~ ^https?:// ]]; then
  JIRA_BASE_URL="https://$JIRA_BASE_URL"
fi

echo "  → $JIRA_BASE_URL"
echo ""

# Step 2 of 8 — Jira project key
echo "Step 2 of 8 — Jira project key"
echo "Example: ENG"
printf "Project key: "
read -r JIRA_PROJECT_KEY

# Auto-uppercase
JIRA_PROJECT_KEY="${JIRA_PROJECT_KEY^^}"

echo "  → $JIRA_PROJECT_KEY"
echo ""

# Step 3 of 8 — Atlassian credentials
echo "Step 3 of 8 — Atlassian credentials"
echo "Generate API token at: https://id.atlassian.com/manage-profile/security/api-tokens"
echo ""

printf "Atlassian email: "
read -r ATLASSIAN_EMAIL

printf "Atlassian API token (visible): "
read -r ATLASSIAN_API_TOKEN

echo "  → Email: $ATLASSIAN_EMAIL"
echo ""

# Step 4 of 8 — Scope
echo "Step 4 of 8 — Where to save credentials"
echo ""
echo "[1] Global  — saves to ~/.zshrc or ~/.bashrc"
echo "              Available in every terminal session automatically."
echo ""
echo "[2] Local   — saves to .env in the current project directory"
echo "              Source manually or use direnv."
echo ""
printf "Choose [1/2] (default: 1): "
read -r SCOPE_CHOICE

if [[ -z "$SCOPE_CHOICE" ]]; then
  SCOPE_CHOICE="1"
fi

echo ""

# ─────────────────────────────────────────────────
# Section B — GitHub Setup
# ─────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🐙 GitHub Setup"
echo "  JADE commits and pushes after every task."
echo "  Your repo must be configured before coding begins."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 5 of 8 — GitHub repository URL
echo "Step 5 of 8 — GitHub repository URL"
echo "This is the repo where JADE will push branches and commits."
echo "Example: https://github.com/yourname/your-repo"
printf "Repository URL: "
read -r GITHUB_REPO_URL

# Strip trailing slash
GITHUB_REPO_URL="${GITHUB_REPO_URL%/}"

# Validate starts with https://github.com/
if [[ ! "$GITHUB_REPO_URL" =~ ^https://github\.com/ ]]; then
  echo "  ⚠️  URL should start with https://github.com/ — proceeding anyway."
fi

echo "  → $GITHUB_REPO_URL"
echo ""

# Step 6 of 8 — GitHub PAT
echo "Step 6 of 8 — GitHub Personal Access Token (PAT)"
echo "Generate at: https://github.com/settings/tokens"
echo "Required scopes: repo (full control of private repositories)"
printf "GitHub PAT (visible): "
read -r GITHUB_PAT

echo ""

# Step 7 of 8 — Default branch
echo "Step 7 of 8 — Default branch name"
printf "What is your default branch? (press enter for 'main'): "
read -r GITHUB_DEFAULT_BRANCH

if [[ -z "$GITHUB_DEFAULT_BRANCH" ]]; then
  GITHUB_DEFAULT_BRANCH="main"
fi

echo "  → $GITHUB_DEFAULT_BRANCH"
echo ""

# Step 8 of 8 — Git identity
echo "Step 8 of 8 — Git identity"
echo "This is how your commits will be attributed in GitHub."
printf "Git user name: "
read -r GIT_USER_NAME

printf "Git user email: "
read -r GIT_USER_EMAIL

echo ""

# ─────────────────────────────────────────────────
# Verify GitHub remote
# ─────────────────────────────────────────────────

echo "Verifying GitHub remote..."
REMOTE_VERIFIED="false"

if git ls-remote "$GITHUB_REPO_URL" HEAD >/dev/null 2>&1; then
  echo "✅ GitHub remote verified."
  REMOTE_VERIFIED="true"

  # Set git identity
  git config user.name "$GIT_USER_NAME"
  git config user.email "$GIT_USER_EMAIL"

  # Set remote if not already set
  if ! git remote get-url origin >/dev/null 2>&1; then
    git remote add origin "$GITHUB_REPO_URL"
    echo "  → Remote origin added."
  fi
else
  echo "❌ Cannot reach $GITHUB_REPO_URL — check the URL and PAT token."
  echo "   Common causes: wrong URL, PAT missing 'repo' scope, repo is private and PAT has no access."
  printf "Would you like to continue anyway? [y/N]: "
  read -r CONTINUE_ANYWAY
  if [[ "$CONTINUE_ANYWAY" != "y" && "$CONTINUE_ANYWAY" != "Y" ]]; then
    echo "Setup cancelled. Run 'claude' again to retry."
    exit 1
  fi
  echo "  ⚠️  Continuing with unverified remote. /jade:apply will check again."
fi

echo ""

# ─────────────────────────────────────────────────
# Write MCP config to ~/.claude.json
# ─────────────────────────────────────────────────

CLAUDE_JSON="$HOME/.claude.json"

# Build base64 for Atlassian Basic auth
ATLASSIAN_BASIC=$(printf '%s:%s' "$ATLASSIAN_EMAIL" "$ATLASSIAN_API_TOKEN" | base64)

# Use python3 or node to merge JSON (available on macOS)
if command -v python3 >/dev/null 2>&1; then
  python3 - "$CLAUDE_JSON" "$ATLASSIAN_BASIC" "$GITHUB_PAT" <<'PYEOF'
import json, sys, os

claude_json_path = sys.argv[1]
atlassian_basic = sys.argv[2]
github_pat = sys.argv[3]

# Read existing config or start fresh
config = {}
if os.path.exists(claude_json_path):
    with open(claude_json_path, 'r') as f:
        try:
            config = json.load(f)
        except json.JSONDecodeError:
            config = {}

# Ensure mcpServers exists
if 'mcpServers' not in config:
    config['mcpServers'] = {}

# Add Atlassian MCP
config['mcpServers']['atlassian'] = {
    "type": "http",
    "url": "https://mcp.atlassian.com/v1/mcp",
    "headers": {
        "Authorization": f"Basic {atlassian_basic}"
    }
}

# Add GitHub MCP
config['mcpServers']['github'] = {
    "type": "http",
    "url": "https://api.githubcopilot.com/mcp",
    "headers": {
        "Authorization": f"Bearer {github_pat}"
    }
}

# Write back
with open(claude_json_path, 'w') as f:
    json.dump(config, f, indent=2)

PYEOF
  echo "✅ MCP servers written to ~/.claude.json (Atlassian + GitHub)"
else
  echo "⚠️  python3 not found — could not update ~/.claude.json automatically."
  echo "   Add MCP servers manually. See JADE README for config format."
fi

# ─────────────────────────────────────────────────
# Write env vars to scope file
# ─────────────────────────────────────────────────

ENV_BLOCK="# jade start
export JIRA_PROJECT_KEY=\"$JIRA_PROJECT_KEY\"
export JIRA_BASE_URL=\"$JIRA_BASE_URL\"
export ATLASSIAN_API_TOKEN=\"$ATLASSIAN_API_TOKEN\"
export ATLASSIAN_EMAIL=\"$ATLASSIAN_EMAIL\"
export GITHUB_REPO_URL=\"$GITHUB_REPO_URL\"
export GITHUB_PAT=\"$GITHUB_PAT\"
export GITHUB_DEFAULT_BRANCH=\"$GITHUB_DEFAULT_BRANCH\"
export GIT_USER_NAME=\"$GIT_USER_NAME\"
export GIT_USER_EMAIL=\"$GIT_USER_EMAIL\"
# jade end"

if [[ "$SCOPE_CHOICE" == "2" ]]; then
  # Local scope — write to .env
  SCOPE_FILE=".env"
  echo "$ENV_BLOCK" >> "$SCOPE_FILE"
  echo "✅ Env vars written to .env (local)"

  # Add .env to .gitignore if inside a git repo
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if ! grep -qxF '.env' .gitignore 2>/dev/null; then
      echo '.env' >> .gitignore
      echo "  → Added .env to .gitignore"
    fi
  fi
else
  # Global scope — write to ~/.zshrc or ~/.bashrc
  if [[ -f "$HOME/.zshrc" ]]; then
    SCOPE_FILE="$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    SCOPE_FILE="$HOME/.bashrc"
  else
    SCOPE_FILE="$HOME/.zshrc"
  fi

  # Remove any existing jade block
  if grep -q '# jade start' "$SCOPE_FILE" 2>/dev/null; then
    sed -i.bak '/# jade start/,/# jade end/d' "$SCOPE_FILE"
    rm -f "${SCOPE_FILE}.bak"
  fi

  echo "$ENV_BLOCK" >> "$SCOPE_FILE"
  echo "✅ Env vars written to $SCOPE_FILE (global)"
fi

# ─────────────────────────────────────────────────
# Mark setup complete
# ─────────────────────────────────────────────────

mkdir -p "$HOME/.claude"
echo "configured on $(date)" > "$CONFIGURED_MARKER"

# ─────────────────────────────────────────────────
# Final summary
# ─────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ JADE setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Jira"
echo "  ─────────────────────────────────────────────"
echo "  Jira URL:        $JIRA_BASE_URL"
echo "  Project key:     $JIRA_PROJECT_KEY"
echo "  Email:           $ATLASSIAN_EMAIL"
echo ""
echo "  GitHub"
echo "  ─────────────────────────────────────────────"
echo "  Repository:      $GITHUB_REPO_URL"
echo "  Default branch:  $GITHUB_DEFAULT_BRANCH"
if [[ "$REMOTE_VERIFIED" == "true" ]]; then
  echo "  Remote verified: ✅"
else
  echo "  Remote verified: ❌ (will retry at /jade:apply)"
fi
echo "  Git identity:    $GIT_USER_NAME <$GIT_USER_EMAIL>"
echo ""
echo "  Config"
echo "  ─────────────────────────────────────────────"
echo "  MCP config:      ~/.claude.json  (Jira + GitHub)"
if [[ "$SCOPE_CHOICE" == "2" ]]; then
  echo "  Env vars:        .env (local)"
else
  echo "  Env vars:        $SCOPE_FILE (global)"
fi
echo ""
if [[ "$SCOPE_CHOICE" != "2" ]]; then
  echo "  👉 Restart your terminal or run: source $SCOPE_FILE"
fi
echo "  👉 To reconfigure: rm ~/.claude/.jade-configured && claude"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
