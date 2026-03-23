#!/usr/bin/env bash
# wait-for-email.sh — Create a disposable inbox, wait for the first email, print its links
# Usage: ./wait-for-email.sh
# Output: JSON of the first received email

set -euo pipefail

API="https://api.agentbasics.dev"

# 1. Create inbox
echo "Creating inbox..." >&2
INBOX=$(curl -s -X POST "$API/v1/email/inboxes" \
  -H "Content-Type: application/json" \
  -d '{"count": 1}')

ADDRESS=$(echo "$INBOX" | python3 -c "import json,sys; print(json.load(sys.stdin)['inboxes'][0]['address'])")
echo "Address: $ADDRESS" >&2

# 2. Poll until email arrives (max 60s)
for i in $(seq 1 20); do
  RESULT=$(curl -s "$API/v1/email/inboxes/$ADDRESS")
  TOTAL=$(echo "$RESULT" | python3 -c "import json,sys; print(json.load(sys.stdin)['total'])" 2>/dev/null || echo "0")

  if [ "$TOTAL" -gt "0" ]; then
    echo "Email received after $((i * 3))s" >&2
    # Print the first email as JSON
    echo "$RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d['emails'][0], indent=2))"
    exit 0
  fi

  echo "Waiting... ($i/20)" >&2
  sleep 3
done

echo "Timeout: no email received after 60 seconds" >&2
exit 1
