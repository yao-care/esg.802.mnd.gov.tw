#!/bin/bash
# regulation-watch.sh — Monitor EPA/MOEA regulation updates
# Schedule: Weekly — internal guard
# Status: Disabled by default in config.json
#
# TODO: Check EPA RSS/API for GHG regulation updates
# TODO: Check MOEA energy regulation updates
# TODO: Output new regulations since last check

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Internal schedule guard: only run on Mondays
DAY_OF_WEEK=$(date +%u)
if [ "$DAY_OF_WEEK" != "1" ] && [ "${FORCE_RUN:-}" != "true" ]; then
  echo "regulation-watch: skipped (not Monday, use FORCE_RUN=true to override)"
  exit 0
fi

echo "=== Regulation Watch ($(date +%Y-%m-%d)) ==="
echo ""
echo "TODO: Implementation pending"
echo "  1. Fetch EPA GHG regulation updates"
echo "     URL: https://ghgregistry.moenv.gov.tw/"
echo "  2. Fetch MOEA energy policy updates"
echo "     URL: https://www.moeaea.gov.tw/"
echo "  3. Compare with last check date"
echo "  4. Output new items"
echo ""
echo "regulation-watch: complete (skeleton only)"
