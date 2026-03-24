#!/usr/bin/env bash
# bulk-signup.sh — Create N inboxes and bulk-check them
# Usage: ./bulk-signup.sh <count>
# Example: ./bulk-signup.sh 3

set -euo pipefail

COUNT="${1:-3}"
API="https://api.agentbasics.dev"

# 1. Create inboxes
echo "Creating $COUNT inboxes..." >&2
INBOXES=$(curl -s -X POST "$API/v1/email/inboxes" \
  -H "Content-Type: application/json" \
  -d "{\"count\": $COUNT}")

echo "Created:" >&2
jq -r '.inboxes[].address' <<< "$INBOXES" >&2

# 2. Build JSON array for bulk check
ADDR_JSON=$(jq '{addresses: [.inboxes[].address]}' <<< "$INBOXES")

# 3. Bulk check (call after using the addresses for signups)
echo ""
echo "Checking inboxes (bulk)..." >&2
BULK=$(curl -s -X POST "$API/v1/email/inboxes/bulk" \
  -H "Content-Type: application/json" \
  -d "$ADDR_JSON")

jq -r '.[] | "\(.address): \(.total) email(s)" + (
  if .total > 0 then
    "\n" + (.emails[] | "  From: \(.from)\n  Subject: \(.subject)" +
      if (.links | length) > 0 then "\n  Links: \(.links | join(", "))" else "" end)
  else "" end
)' <<< "$BULK"
