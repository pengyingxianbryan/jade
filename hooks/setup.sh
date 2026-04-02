#!/usr/bin/env bash
set -euo pipefail

# JADE Session Start Hook
# Checks if JADE is configured for this project. If not, directs user to /jade:init.

CONFIGURED_MARKER=".jade/.configured"

if [[ -f "$CONFIGURED_MARKER" ]]; then
  exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  JADE — Not Configured"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  JADE is not set up for this project."
echo "  Run /jade:init to configure credentials,"
echo "  describe your project, and generate a roadmap."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
