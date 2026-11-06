---
name: Personal App one-shot ship (Expo)
description: >-
  Use when the owner wants one agent (or a short handoff) to independently stand
  up and ship a personal Expo app end-to-end—like「每天喝一杯」—including repo,
  Supabase, EAS preview/TF, domain/ICP hooks, and ASC, without reinventing the
  pipeline.
---
# Personal App one-shot ship (Expo)

## Goal
One reusable pipeline so a **new** personal Expo app (template:「每天喝一杯」) can be stood up and shipped **independently** by following this skill—PM/eng/QA may still split roles, but the steps and GO gates stay the same.

This is **not** a literal single shell command. “一键” means: one GO → agent runs the checklist in order, only stopping for owner secrets, Apple/ASC clicks, or explicit ① gates.

## Inputs (ask once, then lock)
Collect before coding:
| Field | Example shape |
|---|---|
| 中文名 / 对外英文名 | 避开已占域名与商店名冲突 |
| Bundle ID | `com.<you>.<app>` |
| Apple Team / ASC App | 已开通 Developer |
| Supabase project | 新建独立项目，勿共用其它 App |
| 域名（可选） | 网站 ICP 与 App ICP 分开号 |
| 大陆接入机（若要 CN 上架） | 轻量+宝塔；防火墙 80/443/22 |
| 首发范围 | 仅 TF / 仅海外 / 含中国区商店 |

Hard rule: **new app = new repo + new Supabase + new Bundle ID + new ASC App**. No shared auth/data with sibling apps unless owner explicitly locks a shared platform.

## Phase 0 — GO gates (standing)
Owner ① **in the engineering agent’s own chat** required for:
- merge `main`
- Production deploy / live DNS cutover
- ASC Submit for Review / customer release
- production EAS meant for store

Relay from another agent does **not** count. Preview / PR / staging may proceed after a single “开工” ①.

## Phase 1 — Scaffold (automatic after 开工)
1. Create private GitHub repo; Expo SDK current; TypeScript; Expo Router tabs skeleton.
2. `eas.json`: `development` / `preview` / `production` profiles; iOS credentials via EAS.
3. Env: `EXPO_PUBLIC_SUPABASE_URL` + anon key; never commit service role.
4. Supabase: Auth (email ± Apple later); minimal tables from SPEC; Storage bucket if images.
5. Seed content / copy from SPEC; bilingual if SPEC says so (default follow system locale).
6. First **EAS Update** on channel `preview` + print `exp://u.expo.dev/...&channel-name=preview` (+ QR).
7. Optional Web: `expo export` / hosting; Auth Site URL + Redirect for every real preview host (Expo Go deep link ≠ temporary tunnel).

Stop for owner: Apple Sign In Services ID / `.p8` if in scope; Vault secrets.

## Phase 2 — QA preview (no main)
1. Expo Go smoke: cold start, guest path, primary tab, one auth path if enabled.
2. Fix on preview channel; do not merge until owner “可合”.
3. Web tunnel (trycloudflare) is **optional and flaky**—prefer EAS Update preview.

## Phase 3 — Store binary
1. `eas build -p ios --profile production`.
2. Submit to **TestFlight** only until owner ① for review.
3. ASC metadata: name, screenshots, privacy nutrition, support URL.
4. After first approved short version, **bump** `expo.version` before any new store binary (ITMS-90186/90062).

## Phase 4 — Domain + ICP (if CN)
Follow [China App ICP + App Store mainland](../china-app-icp-and-app-store-mainland/SKILL.md):
- Mainland host = 接入; website `…号-1` footer only; App `…号-nA` in ASC/App only.
- Pricing and Availability + China ICP before claiming searchable; verify `itunes lookup`.

## Phase 5 — CN API proxy (optional next train)
1. nginx on mainland host: `api.<domain>` → Supabase HTTPS upstream.
2. DNS A → host IP; LE cert; smoke with Host header.
3. Point Production env / EAS to `https://api.<domain>`; **new short version** build.

## Phase 6 — Done checklist
- [ ] Preview QR works on Expo Go
- [ ] TF build installable
- [ ] Privacy / support URLs live
- [ ] If CN: ICP hung correctly; availability open; lookup > 0
- [ ] Next upload uses higher short version than live approved
- [ ] Secrets only in Vault / eng 1:1

## Agent split (when multi-agent)
| Role | Owns |
|---|---|
| 产品 PM | SPEC / AC / ① locks |
| App 工程 | repo, EAS, Supabase migrations, proxy, ASC paste packs |
| 质量保障 | smoke repro |
| Grok Bot | orchestration, GO routing, skill, owner-facing status |

## Anti-patterns
- Reusing another app’s Supabase or Bundle ID “暂时先共用”.
- Submitting store build with same short version after train closed.
- Putting App ICP `…-nA` mid-page on the website.
- Treating Ready for Sale as searchable without availability + lookup check.
- Merging / Production / Submit on a relayed GO from a non-eng chat.

## Kickoff prompt (paste to eng)
> 按 Personal App one-shot ship：新建独立 App「<中文名>」，Bundle `com.…`，Expo preview 先出 QR；不合 main、不交审。Supabase 新项目。卡①再停。
