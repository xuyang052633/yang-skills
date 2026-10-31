---
name: agent-visual-identity
description: Create or refine a visual identity for an AI agent, including full-body key art, one-line persona, optional cinematic entrance/logo animation, and reference-locked multi-agent sports videos. Use when users ask to visualize an agent, compare bot impressions, reduce or increase anthropomorphism, animate an approved design, or generate a rules-aware 5v5 basketball clip from a cast of agent references.
---

# Agent Visual Identity

## Overview

Use this skill to turn an abstract AI agent into a reusable visual identity: first a full-body “定妆照”/key art, then a concise persona line, and optionally a short motion-graphics-style entrance. The default goal is a memorable silhouette, a restrained palette, one readable tool/prop, and a design that can be reused in later episodes or renders.

## Workflow

1. Extract the identity brief.
2. Generate one portrait key art image.
3. Inspect against the explicit constraints.
4. If the user gives feedback or a comparison image, choose a redesign branch.
5. Deliver the image and one-line persona.
6. If requested, derive a short entrance/logo animation from the approved still.
7. If requested, generate a multi-agent sports clip from the locked cast.
8. Verify the final media and deliver only the final files.

## 1. Extract the identity brief

Record these fields before prompting:

- **Role/anchor:** what the agent does (for example, visual production, research, coding, coordination).
- **Palette:** usually two dominant colors plus one accent.
- **Silhouette:** human, mascot, device, robot, abstract symbol, or hybrid.
- **Prop:** exactly one small, recognizable prop unless the user requests more.
- **Framing:** full body, vertical 3:4 by default; use 9:16 when the asset is primarily for video.
- **Tone:** friendly, reliable, cinematic, technical, playful, etc.
- **Exclusions:** IP characters, trademarks, brand marks, branded sportswear, readable labels, watermarks.

Do not ask for nonessential details. Make a reasonable creative choice when the user has supplied a clear anchor.

## 2. Generate the key art

Use the image-generation tool for a new visual. Write the model prompt in English, while preserving any user-requested visible text exactly; prefer no text for character art. Use an opaque background unless the user explicitly requests transparent output.

Default prompt ingredients:

- “full-body light-chibi character key art”
- “clear readable silhouette, complete head-to-toe framing, generous margin”
- the role-specific prop and visual environment
- two-color lighting scheme and material language
- “no readable text, no watermark, no IP references, no trademarks”

For this workflow, a good default production brief is:

> A full-body light-chibi AI agent identity, with a strong silhouette, one role-defining prop, a cinematic two-color palette, a simple environmental motif, and a polished key-art finish. The design must be recognizable at thumbnail size and reusable for later animation.

Keep the character, prop, palette, and environment coherent. Avoid adding multiple props that compete for recognition.

## 3. Redesign decision tree

### Keep or increase anthropomorphism

Use this branch when the user wants an approachable mascot, companion, host, or character. Preserve the identity anchors and adjust only the requested face, body language, outfit, or expression.

### Reduce anthropomorphism / make the agent’s nature explicit

Use this branch when the user says the result is too human, asks for a more AI-like form, or provides a clearly robotic/non-human comparison.

Change the **subject itself**, not merely the clothing:

- replace human face, hair, skin, and human anatomy;
- use a screen panel, status lights, lens, projector housing, modular shell, or abstract sensor cluster;
- use articulated mechanical joints and device-like proportions;
- make the role visible in the body’s core (for visual production, use a lens, film reel, aperture, tally light, or projector module);
- retain the established palette and setting when continuity matters;
- keep one small prop, such as a clapperboard, and avoid readable labels.

Prompt language should explicitly say “clearly non-human” and “not a person in a costume.” This prevents the model from producing a humanoid actor wearing robot armor.

### Use a comparison image

Treat a comparison image as a reference for the requested dimension only: silhouette, degree of anthropomorphism, palette, or material language. Do not copy logos, labels, trademarked design details, or the other agent’s identity. If the comparison contains brand text, describe the visual idea instead of reproducing the text.

For an edit of an existing key art, use an image-variation workflow and state:

- what to change;
- what to preserve (composition, palette, lighting, environment, framing);
- what to avoid (human anatomy, logos, labels, IP).

## 4. One-line persona

After the visual passes, write exactly one strong sentence that explains the agent’s function through the image. Prefer an active verb and a concrete metaphor.

Good pattern:

> “不是[表面身份]，而是[核心能力]的[视觉/工具隐喻]。”

Example for a non-human visual-production agent:

> “不是扮演导演的机器人，而是一台会把现场直接处理成成片的影视 AI。”

Do not over-explain the image in the persona line; keep any visual notes separate.

## 5. Optional entrance/logo animation

Only generate video after the still is approved or the user explicitly asks for motion. Use the approved still as an image reference; do not invent a new character identity in the video prompt.

Default motion concept for a visual-production AI:

1. near-black and deep-blue film grain;
2. a warm-gold aperture or film-gate sweep;
3. blue rim light reveals the silhouette or activates the chassis;
4. the role-specific device signal appears (lens glow, tally light, reel movement);
5. a short mechanical/cinematic sound cue resolves into a clean final hold.

Describe visible motion, camera movement, ending state, and sound in the prompt. Avoid readable logo text unless exact typography is explicitly required and the user accepts concept-level rendering.

### Aspect ratio and reference handling

- Default still: `3:4`.
- Video: use `portrait`/`9:16` when supported.
- If a 3:4 still is used for a 9:16 video model that requires matching pixel aspect ratio, create a centered crop first. Preserve the full subject; do not stretch or pad after generation.
- Use the session’s currently available video model and plan limits. When the free-plan policy requires it, use MiniMax H3, 5 seconds, and 768p/720p-visible output. Never silently claim 1080p if the selected plan/model cannot provide it.
- Generate at most one clip when the current plan limits video generation to one clip per request.

A concise video prompt should include:

- exact identity preservation from the reference still;
- 3–5 timed visual beats;
- controlled camera push or locked-off motion;
- final logo-like hold without invented text;
- optional synchronized projector, aperture, servo, click, or whoosh sounds.

## 6. Multi-agent 5v5 basketball video

Use this branch when the user asks to place several approved agent identities into a basketball game, scrimmage, or tactical highlight.

### Prepare the cast

1. Build an explicit roster before prompting: exactly 10 players plus exactly 1 referee.
2. Map every named reference image to one unique player identity; never let the model infer missing identities from a prior clip.
3. Add only the minimum number of generic, unbranded street players needed to reach 5v5. For eight named Agents, add exactly two street players.
4. Crop every 3:4 reference to a centered 9:16 frame before a portrait video request. Do not stretch or pad references after the fact.
5. Keep reference count within the selected model's limit. For MiniMax H3, use no more than 9 image references.

### Write the basketball prompt

Specify all of the following in English:

- fixed team rosters, colors, positions, and initial attack direction;
- one consistent broadcast camera side and an explicit no-180-degree-axis-flip rule;
- the referee's clothing, whistle, role, and visibility in the opening tip and scoring signal;
- one orange basketball only, no duplicate players, no extra spectators, no substitutions, and no character morphing;
- timed action beats with legal sequencing: referee tosses tip → two centers jump → legal tip to a named guard → controlled dribble → stationary screen → pass → two-step layup or shot → rim/rebound → outlet pass → fast break → dunk or shot;
- synchronized court sounds: whistle, sneaker squeaks, dribbles, pass impacts, rim contact, rebound, crowd ambience, and final whistle.

For a 15-second vertical highlight, keep the main action chain to one possession and one change of possession. Treat the generated clip as cinematic sports fiction, not a physically verifiable simulation. If tactical accuracy is more important than visual speed, reduce the number of active players in the central action or move to a 3D/game-engine workflow.

### Basketball validation

After generation, inspect technical metadata with `ffprobe` and extract representative frames around the opening tip, ball-handler action, rebound, and finish. Pass only when:

- the file is playable, portrait, and close to the requested duration;
- there is one audio stream when court sound was requested;
- the roster visibly contains the named Agents without obvious duplication or identity substitution;
- the opening includes a referee and a plausible jump ball;
- the ball, basket, court lines, attack direction, and camera side remain coherent enough across sampled frames;
- no extra basketball, brand team uniform, readable invented scoreboard claim, watermark, or unrelated character appears.

Do not claim perfect rule compliance from a few stills; state that the clip passed a lightweight visual/technical check unless the user requests deeper review.

### AI-content disclosure for delivery

For public release, retain any model/platform AI label and add a clear visible disclosure such as `AI GENERATED` when the platform or user requests an on-video mark. Preserve or add ordinary MP4 metadata describing AI generation, human direction, fictional characters/scenes, and the model used. Explain that ordinary metadata may be removed by platform transcoding; the platform's native AI declaration remains necessary.

### Deterministic FFmpeg post-processing

Use `scripts/add_ai_disclosure.sh` when the user asks for a reusable final MP4 with a visible AI mark and ordinary metadata. Do not hand-recreate a one-off command when this script is available. Resolve the script path relative to the skill directory, not to a fixed machine path.

Run:

```bash
<skill-dir>/scripts/add_ai_disclosure.sh \
  input.mp4 output_ai_disclosed.mp4 "AI GENERATED"
```

The script implements this layer and stream pipeline:

```text
input video [0:v]
  → drawtext disclosure layer
    → white text with configurable alpha
    → semi-transparent black box and border
    → right/bottom safe-area margins
  → [vout]

input audio [0:a] (optional)
  → AAC 192 kbps
  → output audio

[vout] + output audio
  → H.264 / yuv420p / libx264
  → +faststart
  → MP4 metadata
  → atomic temporary output rename
```

Default processing parameters are `libx264`, `-preset medium`, `-crf 18`, `yuv420p`, AAC at 192 kbps, and `-movflags +faststart`. Video mapping is explicit (`[vout]`) and audio mapping is optional (`-map 0:a?`) so silent inputs do not fail. The script writes `title`, `artist`, `comment`, `description`, `ai_generated`, `ai_assisted`, `ai_model`, and `human_direction` metadata.

Use these environment variables for controlled changes: `WATERMARK_TEXT`, `FONT_FILE`, `WATERMARK_FONTSIZE`, `WATERMARK_ALPHA`, `BOX_ALPHA`, `MARGIN_X`, `MARGIN_Y`, `VIDEO_CRF`, `VIDEO_PRESET`, `AI_MODEL`, and `HUMAN_DIRECTION`. Prefer the ASCII default `AI GENERATED` when font coverage is uncertain; use a verified CJK font through `FONT_FILE` before placing Chinese text in the video layer. Never deliver a file with tofu/missing-glyph boxes.

The script writes to a temporary MP4, checks that it is non-empty, runs `ffprobe` on the encoded video, and only then renames it to the requested output path. Afterward, extract at least one bottom-right frame to visually verify that the disclosure is complete, inside the frame, legible, and not covering the subject. Ordinary metadata is not a substitute for the platform's native AI declaration or a signed C2PA Content Credential.

## 7. Validation and delivery

Perform a lightweight pass/fail check:

- still is the requested aspect ratio and full body is visible;
- silhouette, dominant palette, and one prop are readable;
- redesign branch is genuinely non-human when requested;
- no obvious trademark, IP character, sports jersey, watermark, or unwanted readable text;
- video is playable, has the requested orientation and approximate duration, and includes audio only when requested;
- final file exists at an absolute sandbox path.

Deliver the final generated image exactly once as a Markdown link. If video was requested, deliver the final MP4 exactly once as a separate link. Include the one-line persona and only essential format details. Do not deliver intermediate crops, prompt files, or contact sheets unless explicitly requested.
