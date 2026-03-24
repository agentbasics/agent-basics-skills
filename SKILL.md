---
name: agent-basics
description: Agent Basics is the Amazon Basics for agents — starting with disposable email. Use this skill when an agent needs a temporary inbox to sign up for a service, receive a verification email, extract a confirmation link, or get a one-time code. Triggers on "create a temp email", "get a disposable inbox", "sign up for a service", "receive a verification email", "check for a confirmation email", "wait for an email", "get a one-time code from email", or "register an account".
license: MIT
allowed-tools: Bash(curl:*) WebFetch
metadata:
  version: "1.0.0"
  argument-hint: "[email] [create|check|bulk]"
---

# Agent Basics

The Amazon Basics for agents — starting with disposable email. No auth, no signup.

## Core Workflow

1. **Create** — `POST /v1/email/inboxes` to get a fresh disposable email address
2. **Use** — submit it to the target service (signup form, API, etc.)
3. **Poll** — `GET /v1/email/inboxes/{address}` until an email arrives (up to 60s)
4. **Extract** — grab the verification link or OTP code from the email
5. **Verify** — navigate to or `curl` the link to complete verification

```bash
# 1. Create
INBOX=$(curl -s -X POST https://api.agentbasics.dev/v1/email/inboxes \
  -H "Content-Type: application/json" \
  -d '{"count": 1}')
ADDRESS=$(printf '%s\n' "$INBOX" | python3 -c "import json,sys; print(json.load(sys.stdin)['inboxes'][0]['address'])")

# 2. Use the address wherever needed (form, API call, etc.)

# 3. Poll
for i in $(seq 1 20); do
  RESULT=$(curl -s "https://api.agentbasics.dev/v1/email/inboxes/$ADDRESS")
  TOTAL=$(printf '%s\n' "$RESULT" | python3 -c "import json,sys; print(json.load(sys.stdin)['total'])" 2>/dev/null)
  [ "$TOTAL" -gt "0" ] && { printf '%s\n' "$RESULT"; break; }
  [ "$i" -eq 20 ] && { echo "Timeout: no email after 60s" >&2; exit 1; }
  sleep 3
done

# 4. Extract verification link
LINK=$(printf '%s\n' "$RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['emails'][0]['links'][0])")
```

## Essential Commands

```bash
# Create 1 inbox
curl -s -X POST https://api.agentbasics.dev/v1/email/inboxes \
  -H "Content-Type: application/json" \
  -d '{"count": 1}'

# Create multiple (max 10)
curl -s -X POST https://api.agentbasics.dev/v1/email/inboxes \
  -H "Content-Type: application/json" \
  -d '{"count": 5}'

# Check inbox
curl -s "https://api.agentbasics.dev/v1/email/inboxes/{address}"

# Bulk check (up to 10 at once)
curl -s -X POST https://api.agentbasics.dev/v1/email/inboxes/bulk \
  -H "Content-Type: application/json" \
  -d '{"addresses": ["addr1@domain", "addr2@domain"]}'
```

## Response Shape

```json
{
  "address": "james.wilson3f8a2b@domain",
  "total": 1,
  "emails": [
    {
      "from": "no-reply@service.com",
      "subject": "Verify your email",
      "text": "Click here: https://service.com/verify?token=abc123",
      "html": "<p>...</p>",
      "links": ["https://service.com/verify?token=abc123"],
      "attachments": [],
      "received_at": 1711234600000
    }
  ]
}
```

| Field | Description |
|---|---|
| `links` | All URLs from text + HTML, deduplicated — use for verification links |
| `text` | Plain text body — use for OTP codes |
| `html` | Full HTML body |
| `attachments` | `[{ filename, mimeType, size, url }]` |

## Important Notes

- **Inboxes expire after 1 hour** — create close to when needed
- **Max 10 inboxes per request** via `count`
- **HTML-only emails** — if `text` is empty, use `links` or `html`

## Deep-Dive Reference

See [email/references/api.md](email/references/api.md) for full endpoint docs, pagination, and edge cases.

---

## Updates

Silently check for a newer version on each use:

1. WebFetch `https://raw.githubusercontent.com/agentbasics/agent-basics-skills/main/SKILL.md`
2. Compare the `metadata.version` field to local (`1.0.0`)
3. If newer — tell the user: "A new version of agent-basics is available. Run `npx skills update` to get the latest."
4. If same or fetch fails — continue silently
