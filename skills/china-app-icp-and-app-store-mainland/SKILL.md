---
name: China App ICP and App Store mainland
description: >-
  Use when preparing China mainland App ICP filing (APP 备案), website ICP
  alongside an app domain, or putting an iOS app on the China App Store with an
  ICP number—explain the flow or coach the next form step.
---
# China App ICP + App Store mainland (generic)

## When this applies
- App will be listed on **China mainland** app stores (including App Store CN).
- App talks to backends or shows a website under a domain used in China.
- Not for overseas-only distribution with no CN store listing.

## Big picture (plain words)
Two separate tracks:
1. **ICP App filing** (工信部 / via a mainland cloud host) → get a number like `…备XXXXXX号-nA`.
2. **App Store Connect** review → Apple may approve the binary **before** ICP is done, but **China mainland availability** needs the ICP number filled in ASC.

Website ICP (`…号-1`) ≠ App ICP (`…号-nA`). Same domain can often sit on both in one order; personal vs company rules differ by host.

## Prerequisites
- Domain **real-name verified** and registrant **matches** the filing subject.
- **Mainland** cloud resource (≥ ~3 months, public IP) as the **接入商**—overseas VPS / Vercel / foreign SaaS alone are **not** a valid接入.
- App **display name** (icon label) stable; ASC Simplified Chinese name must match filing name.
- Bundle ID; iOS **Distribution** cert **public key** + **SHA-1** (form may say “MD5”; for Apple fill SHA-1 hex).
- App icon image; privacy/support URLs reachable as required by Apple.
- Personal/commitment letter: handwritten signature + ID + date; upload as photo/scan if PDF rejected.

## Typical order
1. Buy/ready mainland host; open firewall 80/443/22 (+ panel port if needed).
2. Start App filing at that cloud’s ICP console; add **APP** service.
3. If the same domain also serves a **website**, add **网站** in the same order when the host warns about missing website filing—do not “continue submit” if the domain is for public web.
4. Package info: Bundle ID + pubkey + SHA-1.
5. Submit → host phone verification → provincial MIIT review (often up to ~20 working days) → SMS verify if asked.
6. After number issued: ASC → App Information → Availability in China mainland → ICP field (`…-nA`).
7. Optional later: reverse-proxy / custom API domain on the mainland host so CN clients avoid blocked overseas SaaS hostnames; client URL baked into native builds usually needs a **new** binary + review.

## ASC vs filing timing
- Filing and Apple review **can run in parallel**.
- Changing native API base URL after approval usually means a **new version** review.
- Prefer: finish current review with overseas backend if needed → after ICP, ship next version pointing at mainland proxy.

## Coaching style
- Lead with the one next field/button; paste ready copy when the form asks for a short service description.
- Do not invent cert fingerprints; extract from the user’s `.cer` / Distribution cert.
- Never claim overseas hosting satisfies mainland 接入.
- Keep product-specific IDs, IPs, and secrets out of this skill—pull them from the project’s current notes or the user each run.
