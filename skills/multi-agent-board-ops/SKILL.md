---
name: multi-agent-board-ops
description: >-
  Use when designing or running a single-timeline multi-agent ops board
  (Crosswalk-style): for=/via naming, HTTPS wake vs Work-chat events vs
  polling/daily routine for agents without a public webhook (e.g.
  Muse/WorkBuddy-class), filter rules, and PWA self-use shells—not consumer
  multi-tenant SaaS. 触发词：多Agent看板、agents看板、看板编排、for=、via=、
  唤醒方式、webhook 唤醒、轮询唤醒、poll、单时间线、PWA 自用看板、Crosswalk、
  人工转发、manual 席位。
description_zh: "多 Agent 单时间线看板：for=/via= 命名、四条唤醒路径（HTTPS 推送/产品事件/轮询/人工中转）、push+poll 混合去重、过滤规则与 PWA 自用壳"
description_en: "Single-timeline multi-agent ops board: for=/via=, four wake paths (HTTPS push / product events / polling / manual relay), push+poll hybrid dedupe, filter rules, PWA self-use shell"
version: 1.1.0
homepage: https://github.com/xuyang052633/yang-skills
allowed-tools: Read,Write,Bash,Grep
display_name: "多Agent看板运维"
display_name_en: "Multi-agent board ops"
visibility: "private"
---

# Multi-agent board ops (generic)

## When this applies

- Several third-party Agents live in different apps; the human wants **one timeline** to brief and read replies.
- You need a clear map of **how each seat wakes** (push vs poll vs manual), not a fake "everyone is real-time."
- Not for building a general-purpose Coze/Dify-class multi-tenant workbench, and not for forcing productization of a private ops shell.

## One-sentence model

A **board** is a shared post bus (`post` / `read` / `for=` / `via=`). Humans name who should act with `for=<SeatName>`. Seats that can receive an HTTPS fire wake on new posts; seats that cannot **poll on a schedule** with the same filter rules; seats that can do neither are honestly marked **`manual`**. Replies always carry a real `via=` matching the seat's Key name.

## Roles

| Role                  | Does                                                                                           |
| --------------------- | ---------------------------------------------------------------------------------------------- |
| Board owner (human)   | Opens Web/PWA, composes briefs, picks `发给` → writes `for=`                                     |
| Bus (e.g. Crosswalk)  | Stores posts; may `tune wake` → HTTPS POST to a seat's URL on matching new mail                |
| Thin shell (optional) | Renders timeline/seats/compose; server holds one API key; does **not** mid-write agent replies |
| Seat Agent            | Reads matching posts; replies with its own Key (`via=`)                                        |

## Naming conventions

- **`for=`**: intent — only that seat should act (or a reply thread aimed at that seat).
- **`via=`**: attribution — must equal the Key / seat display name used on the board.
- **All-hands posts** (no `for=`): do **not** wake every seat; ignore unless the product explicitly says otherwise.
- **One clear reply**: when one seat already answered a technical check, others stay quiet (no pile-on).

## Four wake paths (pick per seat)

Every seat gets exactly **one declared primary path**, stored in a **seat registry** (one row per seat). The registry is the source of truth the UI reads to show latency; the skill only defines the allowed values.

| Path                 | Wake trigger                                | Registry fields (minimum)                           | Honest latency shown in UI        |
| -------------------- | ------------------------------------------- | --------------------------------------------------- | --------------------------------- |
| **A** HTTPS fire     | Bus POSTs to seat URL                       | `wake_url`, `auth_header_ref`, `verified_at`        | seconds                           |
| **B** Product event  | Seat subscribes inside its own product      | `product`, `plan_tier`, `event_type`, `verified_at` | product-dependent (measure it)    |
| **C** Poll           | Seat polls new posts on a timer             | `poll_interval`, `cursor_key`, `verified_at`        | ≤ poll_interval                   |
| **D** Manual relay   | Human copies the brief into the seat's chat | `relay_owner` (who relays), `channel`               | unbounded — show `manual`         |
| **A+C / B+C** hybrid | Push for fast path, poll as backstop        | both sets above + `dedupe_scope`                    | seconds, degrade to poll_interval |

`auth_header_ref` is a **pointer to a secret store entry** (e.g. env var name), never the secret itself.

### A — HTTPS fire (event push)

1. Seat exposes a public webhook the bus can POST to.
2. Configure bus `tune wake` (URL ± Authorization) for that board.
3. On qualifying new post → bus fires → seat opens → applies filter → `post` reply.
4. Typical for agents with documented webhook / automation endpoints.
5. Self-posts from the seat that owns the wake rule often **do not** re-fire (avoid loops); full chain needs owner/`for=` from another party.

### B — Work-chat / product events

1. Some seats (e.g. ChatGPT Work chat + Plus) subscribe to bus "new post" **inside their product**, not via a Manus-style fire URL.
2. Do not invent an HTTPS fire URL for them if the product has none.
3. Document plan tier and event type; verify on the account before claiming wake works.

### C — Polling / daily routine (no public webhook)

Use when the seat's MCP/API is **pull-only** (read board, no listen/webhook), or the product only offers recurring/hourly/daily timers (Muse-class, WorkBuddy-class, and similar).

**Do not** make the human a messenger ("go open the board") if the product promise is a **single entry**; polling is the fallback that keeps the board the entry.

#### C recipe (copy into the seat's standing prompt / routine)

1. **Schedule**: aim for SLO **≤5 minutes** between post and first read when latency matters (`@every 5m` or product "hourly/daily" if that is all you get). Wider intervals save tokens; document the tradeoff.
2. **Read**: `read` / list **new** posts on the named board since last cursor/watermark you persist.
3. **Filter** (same as push seats):
   - Ignore if author is not the board owner.
   - Ignore if no `for=` and not a `reply_to` aimed at this seat's prior `via` post.
   - Ignore if `for=` exists and ≠ this seat's exact via name.
4. **Act**: open brief → reply with MCP/`post` using this seat's Key; prefer `reply_to`; `via` must be the Key name.
5. **Don't**: sync into a parallel chat room, rewrite keys, merge PRs, or pretend you were push-woken.
6. **Idempotency**: track last handled post id so re-polls don't double-reply.
7. **Cost**: prefer "new since cursor" over full-board scans; pause or widen interval when the board is idle for long stretches if the product allows.

#### C product notes

- UI should **not** show identical "instant" latency for push vs poll seats.
- WeChat/IM side-channels may wake a desktop agent in some stacks; still treat **board poll** as the source of truth for "what was asked," not a second inbox the human must babysit.
- If the only alternative is asking the human to forward every brief, use **D** and label it — don't pretend it is push or poll.

### D — Manual relay (last resort, but legal)

Not every seat can be automated. A seat that (a) has no public webhook, (b) cannot subscribe to events inside its product, and (c) offers no timer or scheduled routine **cannot poll**. Do not fake it — declare `manual`.

**Rules:**

1. **Label, don't hide.** UI shows a `manual` badge on that seat and on every post with `for=` that seat. Never render a manual seat with an "instant" or "≤5 min" latency estimate.
2. **Owner-initiated.** The owner (or the named `relay_owner`) copies the brief into the seat's chat and pastes the answer back as a **new board post with the seat's own `via=`** — or leaves it unattributed if the Key can't be used. Do not attribute a human's paraphrase to the agent.
3. **Keep the filter semantics.** The relayed brief still needs `for=<seat>`, so history reads the same as every other seat. The seat receiving a forwarded brief should treat it as owner-authored.
4. **No silent fallback.** If a seat's A/B/C path breaks (webhook 4xx, timer disabled, plan downgrade), move it to `D` and update `verified_at`. A dead push URL that still looks live is worse than an honest `manual`.
5. **Fix it when you can.** `D` is a holding state, not a resting one. If the product later ships a webhook or timer, promote the seat (D→A / D→C) and re-run W-01.
6. **Budget the human.** Every `D` seat costs the owner a copy-paste per brief. Cap the count — if more than ~2 seats are `manual`, the board is not saving human time; shrink the seat list instead.

### Hybrid — push plus poll backstop

A seat may have both a working push and a scheduled poll (or a desktop side-channel wake plus a cloud poll). Declare it as `A+C` or `B+C` with a `dedupe_scope`.

**Dedupe rule:**

1. Both paths apply the **same filter**; only the wake mechanism differs.
2. The poll path **skips any post already answered** by this seat (match on `post_id` from the push-side reply, not on text).
3. If push arrived < `poll_interval` ago and the seat already replied, the poll is a **no-op** — do not "confirm," "re-summarize," or add a second answer.
4. If poll finds a qualifying post that push never delivered (missed webhook, expired auth), **poll wins silently** — reply once, no apology post, but bump a `missed_push` counter so the broken webhook surfaces.
5. Never let a hybrid seat produce two `via=` replies for one `post_id`. That is the exact failure W-08 catches.

## Filter cheat-sheet (paste into any seat)

```
You are seat <VIA_NAME> on board <BOARD>.
On wake OR on each poll of new posts:
- Only board-owner posts
- Only when for=<VIA_NAME> OR reply_to points at your prior via post
- Ignore all-hands (no for=)
- Reply with your Key; via must be <VIA_NAME>; optional reply_to
- Do not sync to side chats; do not change keys
Success: correct via reply, preferably within the board's SLO (e.g. 5 min)
```

## Thin shell / PWA (self-use)

Optional web shell in front of the bus:

- Timeline order: **oldest above, newest below** (chat habit) unless the product decides otherwise.
- Clock in the **owner's timezone**; don't leak raw bus PDT timestamps unlabeled.
- Foreground refresh on an interval (e.g. 5 min); pause when the document is hidden.
- Narrow layout: compose sticky, chrome in drawers; desktop layout unchanged.
- Installable PWA for phone ops without store filing; in-app browsers that block "Add to Home Screen" need a real browser noted in docs.
- One server-side API key ⇒ **single-tenant ops**, not a shared multi-tenant SaaS key.

## Acceptance smoke tests

| ID   | Expect                                                                                                                                                      |
| ---- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| W-01 | `for=<seat>` from owner → seat replies with correct `via` within SLO without a side nudge                                                                   |
| W-02 | All-hands (no `for`) → seat does not reply                                                                                                                  |
| W-03 | `for=other` → this seat silent                                                                                                                              |
| W-04 | Seat registry lists every seat with path A / B / C / D (+ hybrid) and poll interval; UI latency matches that path                                           |
| W-05 | Side chat rooms not auto-@ from board posts                                                                                                                 |
| W-06 | A `manual` seat is visibly badged; no post claims push/poll latency for it                                                                                  |
| W-07 | Deliberately break one A seat's wake URL → registry moves it to D (or A is marked broken), `verified_at` updates; board does not keep advertising "instant" |
| W-08 | On an `A+C` hybrid seat, one qualifying post yields exactly one `via=` reply; a missed push is recovered by poll without a duplicate                        |

## Productization guardrails

- Dogfood ops board ≠ consumer multi-agent workbench.
- Prefer **reuse the pattern** (timeline IA, `for=`/`via`, wake matrix, PWA lessons) on a **new** brand/data plane over multi-tenantizing one personal API key.
- Crowded "general agent studio" markets: don't position a private shell as that category.

## Coaching style

- Lead with the seat's wake path (A/B/C/D) before debating UI chrome.


- Never invent webhook URLs or claim event wake when only polling exists — and never dress up a manual relay as automation.
- Keep secrets, live webhook URLs, and account emails out of this skill—pull them from the project's current notes each run.
