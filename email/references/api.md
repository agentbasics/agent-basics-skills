# Agent Basics Email — Full API Reference

Base URL: `https://api.agentbasics.dev`

No authentication required.

---

## POST /v1/email/inboxes

Create one or more disposable inboxes.

**Request:**
```json
{ "count": 1 }
```

| Field | Type | Default | Description |
|---|---|---|---|
| `count` | number | 1 | Number of inboxes to create (1–10) |

**Response:**
```json
{
  "inboxes": [
    { "address": "james.wilson3f8a2b@<domain>", "created_at": 1711234567890, "expires_at": 1711238167890 }
  ]
}
```

---

## GET /v1/email/inboxes/{address}

Fetch emails for an inbox.

**Query params:**
| Param | Default | Description |
|---|---|---|
| `page` | `0` | Zero-indexed page number |
| `limit` | `20` | Emails per page (1–50) |

**Response:**
```json
{
  "address": "james.wilson3f8a2b@<domain>",
  "created_at": 1711234567890,
  "expires_at": 1711238167890,
  "total": 2,
  "page": 0,
  "limit": 20,
  "emails": [ ...EmailObject ]
}
```

---

## POST /v1/email/inboxes/bulk

Check multiple inboxes in one request.

**Request:**
```json
{ "addresses": ["addr1@<domain>", "addr2@<domain>"] }
```

**Response:** Array — same shape as single GET per inbox.

```json
[
  { "address": "addr1@<domain>", "created_at": 1711234567890, "expires_at": 1711238167890, "total": 1, "emails": [...] },
  { "address": "addr2@<domain>", "created_at": 1711234567890, "expires_at": 1711238167890, "total": 0, "emails": [] }
]
```

---

## EmailObject

```typescript
{
  from: string           // Sender address
  subject: string        // Email subject
  text: string           // Plain text body (decoded, clean)
  html: string           // Full HTML body (may be empty if text-only email)
  links: string[]        // All URLs extracted from text + HTML, deduplicated
  attachments: Attachment[]
  received_at: number    // Unix timestamp (ms)
}
```

## Attachment

```typescript
{
  filename: string       // Original filename
  mimeType: string       // e.g. "application/pdf", "image/png"
  size: number           // Bytes
  url: string            // https://attachments.agentbasics.dev/{key}
}
```

Attachment files are publicly accessible via the `url` field — download directly with `curl -sO`.

---

## Edge Cases

- **Expired inbox**: Returns `404` after 1 hour
- **No emails yet**: Returns `total: 0, emails: []` (not an error — keep polling)
- **HTML-only emails**: `text` will be empty, use `html` or `links`
- **Large emails**: Paginate with `?page=1&limit=20`
- **Attachments**: Download immediately — not guaranteed to persist forever
