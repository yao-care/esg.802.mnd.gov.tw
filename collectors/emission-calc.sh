#!/bin/bash
# emission-calc.sh — Monthly emission calculation from FRM data
# Schedule: Monthly (1st of month) — internal guard
#
# TODO: Read FRM monthly data files from data/collected/ or submitted forms
# TODO: Apply emission factors from knowledge/GDL-CALC-METHOD/
# TODO: Output calculated emissions summary to data/reported/

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Internal schedule guard: only run on 1st of month
DAY_OF_MONTH=$(date +%d)
if [ "$DAY_OF_MONTH" != "01" ] && [ "${FORCE_RUN:-}" != "true" ]; then
  echo "emission-calc: skipped (not 1st of month, use FORCE_RUN=true to override)"
  exit 0
fi

echo "=== Emission Calculation ($(date +%Y-%m)) ==="
echo ""
echo "TODO: Implementation pending"
echo "  1. Read monthly fuel/electricity/refrigerant data"
echo "  2. Apply emission factors"
echo "  3. Calculate tCO2e per source"
echo "  4. Output summary report"
echo ""
echo "emission-calc: complete (skeleton only)"
