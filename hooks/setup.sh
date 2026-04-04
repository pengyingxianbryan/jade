#!/usr/bin/env bash
set -euo pipefail

# PM Session Start Hook
# Checks if PM is configured for this project. If not, directs user to /pm:init.

CONFIGURED_MARKER=".pm/.configured"

if [[ -f "$CONFIGURED_MARKER" ]]; then
  exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  PM — Not Configured"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  PM is not set up for this project."
echo "  Run /pm:init to configure GitHub,"
echo "  describe your project, and generate a roadmap."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
