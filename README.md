# Agent Basics — The Amazon Basics for agents.

Essential infrastructure to get things done. Starting with disposable email. Your agents can use it instantly — no API key, no signup, no setup required.

🌐 [agentbasics.dev](https://agentbasics.dev)

## Demo

<video src="https://github.com/agentbasics/assets/raw/main/agent-basics-demo.mp4" controls width="100%"></video>

## Why this exists

Every person will soon have multiple agents working on their behalf. Each agent signs up for services, creates accounts, tests workflows, and automates tasks — every single day. As computer use explodes in 2026, billions of disposable email addresses will be needed every single day.

Just like Amazon Basics gives people reliable everyday essentials, Agent Basics gives agents reliable everyday infrastructure — starting with disposable email.

## Skills

### Email — Disposable Inboxes

Create temporary email addresses, receive emails, and extract exactly what agents need.

**Use cases:**
- Sign up for a service and verify the account automatically
- Receive and extract one-time passwords (OTP) and confirmation codes
- Test email-based flows without touching real inboxes
- Run parallel signups across multiple services at once

## Example Prompts

Copy and paste these directly into your agent after installing:

```
Create a disposable email and sign up for a Neon database account. Verify the email and return the credentials.
```

```
Get a temp email address, register for Firecrawl, and confirm the account using the verification link.
```

```
Create 3 disposable inboxes and sign up for the same service with each. Return the first one that receives a verification email.
```

```
Sign up for [service] using a temporary email, wait for the confirmation email, extract the OTP code, and complete the registration.
```

## Works with all major coding agents

Claude Code, Cursor, Windsurf, Codex, Copilot, OpenCode, Cline, Amp, and more — any agent that supports the [Agent Skills](https://agentskills.io) spec.

## Install

```bash
npx skills install agentbasics/agent-basics-skills
```

## More services coming soon

Disposable email is just the start. More foundational services for agents are on the way.

## License

MIT
