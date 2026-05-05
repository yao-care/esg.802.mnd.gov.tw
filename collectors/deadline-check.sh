#!/bin/bash
# deadline-check.sh — Check milestone due dates from MTX-TIMELINE
# Usage: bash collectors/deadline-check.sh [--days N]
# Exit: always 0 (informational)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MILESTONES_FILE="$PROJECT_ROOT/knowledge/MTX-TIMELINE/milestones.yaml"
DAYS=30

# Parse --days argument
while [[ $# -gt 0 ]]; do
  case "$1" in
    --days)
      DAYS="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [ ! -f "$MILESTONES_FILE" ]; then
  echo "ERROR: milestones.yaml not found at $MILESTONES_FILE"
  exit 0
fi

echo "=== Deadline Check ($(date +%Y-%m-%d), window: ${DAYS} days) ==="
echo ""

# Get today's epoch seconds (GNU date primary, BSD date fallback)
today_epoch() {
  if date -d "today" +%s 2>/dev/null; then
    return
  fi
  # BSD date fallback
  date -j -f "%Y-%m-%d" "$(date +%Y-%m-%d)" +%s 2>/dev/null
}

date_to_epoch() {
  local d="$1"
  if date -d "$d" +%s 2>/dev/null; then
    return
  fi
  # BSD date fallback
  date -j -f "%Y-%m-%d" "$d" +%s 2>/dev/null
}

TODAY=$(today_epoch)
WINDOW_SECS=$(( DAYS * 86400 ))

OVERDUE=0
UPCOMING=0
ON_TRACK=0

# Parse YAML: extract blocks starting with "  - id:" and collect fields
# We accumulate per-milestone fields then process when we hit the next entry
process_milestone() {
  local id="$1" name="$2" category="$3" due_date="$4" status="$5" owner="$6"

  # Skip if due_date is null or empty
  if [ -z "$due_date" ] || [ "$due_date" = "null" ]; then
    return
  fi

  local due_epoch
  due_epoch=$(date_to_epoch "$due_date" 2>/dev/null) || {
    echo "  [WARN] Cannot parse due_date '$due_date' for $id"
    return
  }

  local diff=$(( due_epoch - TODAY ))

  if [ "$diff" -lt 0 ]; then
    echo "  [OVERDUE]   $id — $name ($category)"
    echo "              due: $due_date  owner: $owner  status: $status"
    OVERDUE=$(( OVERDUE + 1 ))
  elif [ "$diff" -le "$WINDOW_SECS" ]; then
    local days_left=$(( diff / 86400 ))
    echo "  [UPCOMING]  $id — $name ($category)"
    echo "              due: $due_date  days_left: ${days_left}  owner: $owner  status: $status"
    UPCOMING=$(( UPCOMING + 1 ))
  else
    local days_left=$(( diff / 86400 ))
    echo "  [ON-TRACK]  $id — $name ($category)"
    echo "              due: $due_date  days_left: ${days_left}  owner: $owner  status: $status"
    ON_TRACK=$(( ON_TRACK + 1 ))
  fi
}

# Read milestones.yaml line by line and parse each milestone block
cur_id="" cur_name="" cur_category="" cur_due_date="" cur_status="" cur_owner=""
in_milestones=false

while IFS= read -r line; do
  # Detect start of milestones list
  if echo "$line" | grep -q "^milestones:"; then
    in_milestones=true
    continue
  fi

  if [ "$in_milestones" = false ]; then
    continue
  fi

  # New milestone entry
  if echo "$line" | grep -qE "^  - id:"; then
    # Process previous milestone if exists
    if [ -n "$cur_id" ]; then
      process_milestone "$cur_id" "$cur_name" "$cur_category" "$cur_due_date" "$cur_status" "$cur_owner"
    fi
    cur_id=$(echo "$line" | awk -F': ' '{print $2}' | tr -d '[:space:]')
    cur_name="" cur_category="" cur_due_date="" cur_status="" cur_owner=""
    continue
  fi

  # Skip if not inside a milestone block yet
  if [ -z "$cur_id" ]; then
    continue
  fi

  # Parse fields (lines indented with 4 spaces)
  if echo "$line" | grep -qE "^    name:"; then
    cur_name=$(echo "$line" | sed 's/^    name: *//')
  elif echo "$line" | grep -qE "^    category:"; then
    cur_category=$(echo "$line" | sed 's/^    category: *//')
  elif echo "$line" | grep -qE "^    due_date:"; then
    cur_due_date=$(echo "$line" | sed 's/^    due_date: *//' | tr -d '[:space:]')
  elif echo "$line" | grep -qE "^    status:"; then
    cur_status=$(echo "$line" | sed 's/^    status: *//' | tr -d '[:space:]')
  elif echo "$line" | grep -qE "^    owner:"; then
    cur_owner=$(echo "$line" | sed 's/^    owner: *//')
  fi
done < "$MILESTONES_FILE"

# Process last milestone
if [ -n "$cur_id" ]; then
  process_milestone "$cur_id" "$cur_name" "$cur_category" "$cur_due_date" "$cur_status" "$cur_owner"
fi

echo ""
echo "--- Summary ---"
echo "  OVERDUE:  $OVERDUE"
echo "  UPCOMING: $UPCOMING (within ${DAYS} days)"
echo "  ON-TRACK: $ON_TRACK"
echo ""

exit 0
