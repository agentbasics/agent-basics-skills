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

# Extract addresses
ADDRESSES=$(echo "$INBOXES" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for inbox in data['inboxes']:
    print(inbox['address'])
")

echo "Created:" >&2
echo "$ADDRESSES" >&2

# 2. Build JSON array for bulk check
ADDR_JSON=$(echo "$ADDRESSES" | python3 -c "
import json, sys
addrs = [line.strip() for line in sys.stdin if line.strip()]
print(json.dumps({'addresses': addrs}))
")

# 3. Bulk check (call after using the addresses for signups)
echo ""
echo "Checking inboxes (bulk)..." >&2
curl -s -X POST "$API/v1/email/inboxes/bulk" \
  -H "Content-Type: application/json" \
  -d "$ADDR_JSON" | python3 -c "
import json, sys
results = json.load(sys.stdin)
for inbox in results:
    print(f'{inbox[\"address\"]}: {inbox.get(\"total\", 0)} email(s)')
    for email in inbox.get('emails', []):
        print(f'  From: {email[\"from\"]}')
        print(f'  Subject: {email[\"subject\"]}')
        if email.get('links'):
            print(f'  Links: {email[\"links\"]}')
"
