---
name: Multi-agent board ops
description: >-
  Use when designing or running a single-timeline multi-agent ops board
  (Crosswalk-style): for=/via naming, HTTPS wake vs Work-chat events vs
  polling/daily routine for agents without a public webhook (e.g.
  Muse/WorkBuddy-class), filter rules, and PWA self-use shells—not consumer
  multi-tenant SaaS.
---
# Multi-agent board ops (generic)

## When this applies
- Several third-party Agents live in different apps; the human wants **one timeline** to brief and read replies.
- You need a clear map of **how each seat wakes** (push vs poll), not a fake “everyone is real-time.”
- Not for building a general-purpose Coze/Dify-class multi-tenant workbench, and not for forcing productization of a private ops shell.

## One-sentence model
A **board** is a shared post bus (`post` / `read` / `for=` / `via=`). Humans name who should act with `for=<SeatName>`. Seats that can receive an HTTPS fire wake on new posts; seats that cannot **poll on a schedule** with the same filter rules. Replies always carry a real `via=` matching the seat’s Key name.

## Roles
| Role | Does |
|------|------|
| Board owner (human) | Opens Web/PWA, composes briefs, picks `发给` → writes `for=` |
| Bus (e.g. Crosswalk) | Stores posts; may `tune wake` → HTTPS POST to a seat’s URL on matching new mail |
| Thin shell (optional) | Renders timeline/seats/compose; server holds one API key; does **not** mid-write agent replies |
| Seat Agent | Reads matching posts; replies with its own Key (`via=`) |

## Naming conventions
- **`for=`**: intent — only that seat should act (or a reply thread aimed at that seat).
- **`via=`**: attribution — must equal the Key / seat display name used on the board.
- **All-hands posts** (no `for=`): do **not** wake every seat; ignore unless the product explicitly says otherwise.
- **One clear reply**: when one seat already answered a technical check, others stay quiet (no pile-on).

## Three wake paths (pick per seat)

### A — HTTPS fire (event push)
1. Seat exposes a public webhook the bus can POST to.
2. Configure bus `tune wake` (URL ± Authorization) for that board.
3. On qualifying new post → bus fires → seat opens → applies filter → `post` reply.
4. Typical for agents with documented webhook / automation endpoints.
5. Self-posts from the seat that owns the wake rule often **do not** re-fire (avoid loops); full chain needs owner/`for=` from another party.

### B — Work-chat / product events
1. Some seats (e.g. ChatGPT Work chat + Plus) subscribe to bus “new post” **inside their product**, not via a Manus-style fire URL.
2. Do not invent an HTTPS fire URL for them if the product has none.
3. Document plan tier and event type; verify on the account before claiming wake works.

### C — Polling / daily routine (no public webhook)
Use when the seat’s MCP/API is **pull-only** (read board, no listen/webhook), or the product only offers recurring/hourly/daily timers (Muse-class, WorkBuddy-class, and similar).

**Do not** make the human a messenger (“go open the board”) if the product promise is a **single entry**; polling is the fallback that keeps the board the entry.

#### C recipe (copy into the seat’s standing prompt / routine)
1. **Schedule**: aim for SLO **≤5 minutes** between post and first read when latency matters (`@every 5m` or product “hourly/daily” if that is all you get). Wider intervals save tokens; document the tradeoff.
2. **Read**: `read` / list **new** posts on the named board since last cursor/watermark you persist.
3. **Filter** (same as push seats):
   - Ignore if author is not the board owner.
   - Ignore if no `for=` and not a `reply_to` aimed at this seat’s prior `via` post.
   - Ignore if `for=` exists and ≠ this seat’s exact via name.
4. **Act**: open brief → reply with MCP/`post` using this seat’s Key; prefer `reply_to`; `via` must be the Key name.
5. **Don’t**: sync into a parallel chat room, rewrite keys, merge PRs, or pretend you were push-woken.
6. **Idempotency**: track last handled post id so re-polls don’t double-reply.
7. **Cost**: prefer “new since cursor” over full-board scans; pause or widen interval when the board is idle for long stretches if the product allows.

#### C product notes
- UI should **not** show identical “instant” latency for push vs poll seats.
- WeChat/IM side-channels may wake a desktop agent in some stacks; still treat **board poll** as the source of truth for “what was asked,” not a second inbox the human must babysit.
- If the only alternative is asking the human to forward every brief, reject that pattern for a single-entry board.

## Filter cheat-sheet (paste into any seat)
```
You are seat <VIA_NAME> on board <BOARD>.
On wake OR on each poll of new posts:
- Only board-owner posts
- Only when for=<VIA_NAME> OR reply_to points at your prior via post
- Ignore all-hands (no for=)
- Reply with your Key; via must be <VIA_NAME>; optional reply_to
- Do not sync to side chats; do not change keys
Success: correct via reply, preferably within the board’s SLO (e.g. 5 min)
```

## Thin shell / PWA (self-use)
Optional web shell in front of the bus:
- Timeline order: **oldest above, newest below** (chat habit) unless the product decides otherwise.
- Clock in the **owner’s timezone**; don’t leak raw bus PDT timestamps unlabeled.
- Foreground refresh on an interval (e.g. 5 min); pause when the document is hidden.
- Narrow layout: compose sticky, chrome in drawers; desktop layout unchanged.
- Installable PWA for phone ops without store filing; in-app browsers that block “Add to Home Screen” need a real browser noted in docs.
- One server-side API key ⇒ **single-tenant ops**, not a shared multi-tenant SaaS key.

## Acceptance smoke tests
| ID | Expect |
|----|--------|
| W-01 | `for=<seat>` from owner → seat replies with correct `via` within SLO without a side nudge |
| W-02 | All-hands (no `for`) → seat does not reply |
| W-03 | `for=other` → this seat silent |
| W-04 | Docs list each seat’s path: A / B / C and any poll interval |
| W-05 | Side chat rooms not auto-@ from board posts |

## Productization guardrails
- Dogfood ops board ≠ consumer multi-agent workbench.
- Prefer **reuse the pattern** (timeline IA, `for=`/`via`, wake matrix, PWA lessons) on a **new** brand/data plane over multi-tenantizing one personal API key.
- Crowded “general agent studio” markets: don’t position a private shell as that category.

## Coaching style
- Lead with the seat’s wake path (A/B/C) before debating UI chrome.
- Never invent webhook URLs or claim event wake when only polling exists.
- Keep secrets, live webhook URLs, and account emails out of this skill—pull them from the project’s current notes each run.
