# Security Policy

CUST/OS is AI tooling for tactical environments. We take security seriously and appreciate the efforts of security researchers to identify and disclose vulnerabilities responsibly.

## Reporting a vulnerability

**Please do not report security vulnerabilities through public GitHub issues, discussions, or pull requests.**

Instead, report them privately by email to **security@nimbusxr.us**.

Include as much of the following as you can:

- A description of the vulnerability and its impact
- The component affected (a specific skill, the install script, the plugin runtime, a configuration option)
- Steps to reproduce
- Any proof-of-concept code or payloads (attach as a `.txt` file rather than pasting inline)
- Your disclosure timeline expectations
- Whether you'd like to be credited in the fix announcement (and how)

We will acknowledge receipt within **72 hours** and provide an initial assessment within **7 days**. For confirmed vulnerabilities we will coordinate a disclosure timeline with you; we aim to ship a fix within 30 days for critical issues, 90 days for lower-severity findings.

## Scope

This repository covers:

- The skill kit (`skills/`)
- Starter configuration (`custos.yaml`)
- Scratches (`scratches/`) and the install script

If the vulnerability is in the CUST/OS plugin itself (the Android APK, its runtime, or the sandbox), please still report to the email above — we'll route it to the right team.

## Out of scope

- Issues affecting only modified / forked versions of the skill kit
- Issues in the ATAK host application itself (report those to TAK Product Center)
- Issues in third-party LLM providers (Anthropic, OpenAI, xAI, etc.) — report to the provider directly
- Social engineering attacks against contributors or users
- Denial of service against a personal device via operator-configured skills (the operator controls their own sandbox)

## Safe harbor

We support safe-harbor research conducted in good faith. We will not pursue legal action against researchers who:

- Report vulnerabilities through the private channel above
- Make a good-faith effort to avoid privacy violations and disruption of service
- Do not exploit the vulnerability beyond what's necessary to demonstrate it
- Give us reasonable time to remediate before public disclosure

## Credit

With your permission, we'll credit you in the release notes and the security advisory. If you prefer to remain anonymous, just let us know.
