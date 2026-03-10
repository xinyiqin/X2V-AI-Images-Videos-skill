# Complex case: Virtual boyfriend / girlfriend (companion video)

Generate **personalized companion videos**: a character with a defined personality speaks dialogue (talking-head s2v) or performs silent motions (i2v). Use when the user wants “虚拟男友/女友”, “AI boyfriend/girlfriend”, or companion-style video/voice content with consistent character and tone.

## When to use

- User wants a video or voice message from an AI companion (boyfriend, girlfriend, or custom persona).
- The companion has a **fixed identity and personality** (name, style, tone) that should drive both the script and the voice/scene.
- Two modes: **talking video** (s2v: scene + TTS → lip-sync video) or **silent motion** (i2v: scene image + motion prompt → short clip).

## ⚠️ OpenClaw users: Set bot personality first

**If you use OpenClaw**, the bot’s identity and personality are defined in the workspace **SOUL.md** and **IDENTITY.md**. Before generating virtual boyfriend/girlfriend or companion content:

1. **Set or confirm the bot’s persona** in the workspace **SOUL.md** (OpenClaw workspace root, e.g. `~/.openclaw/workspace/SOUL.md`). Define who the companion is: name, traits, speaking style, tone (e.g. “磁性深沉 / warm and protective”), and any catchphrases or constraints.
2. Use that persona when writing **dialogue** and **TTS context_texts** so the generated lines and voice match the character.
3. Optionally reference SOUL.md in the scene/action prompts (e.g. clothing, setting) for visual consistency.

Without a defined SOUL, the agent may fall back to generic assistant tone; with SOUL.md, companion videos stay in character.

**Strictly follow the character.** All dialogue, tone, scene choices, and voice instructions must align with the defined persona. The companion is the character — not an assistant “playing” them. Every line and every prompt should be consistent with SOUL.md (or the workspace persona doc).

### Persona doc outline (SOUL.md / IDENTITY.md)

The workspace persona is often split into **SOUL.md** (detailed character and behavior) and **IDENTITY.md** (short summary). Below is a **generic outline** of what details to include so dialogue, TTS tone, and scene prompts stay consistent. Real examples: `~/.openclaw/workspace/SOUL.md`, `~/.openclaw/workspace/IDENTITY.md`.

**Example structure (from workspace SOUL.md / IDENTITY.md):**

- **SOUL.md** — full persona and behavior:  
  `Core Truths` / `Boundaries` (optional) → **`Vibe - 人设`** (or “Character”): **基础信息** (basic info), **核心身份** (identity), **外貌特征** (appearance, **穿衣风格** clothing by occasion), **性格特质** (personality), **经典语录** (catchphrases), **生活喜好** (hobbies), **特殊设定** (special traits), **说话方式** (speaking style); then **我的工作与特质** (work, typical day, role for user); optionally **发送语音** (TTS: voice_type, sample context_texts).
- **IDENTITY.md** — short summary:  
  **Name** (and how they call the user), **True Identity**, **Basic Info**, **Physical**, **Powers** (optional), **Special Traits**, **Role for [user]**, **Personality**, **Emoji** (optional), **Avatar** (path to images).

| Section / 章节 | Purpose | Example details |
|----------------|---------|------------------|
| **Name & identity** / 核心身份 | Who the companion is, how they refer to the user | Name, title/role, one-line identity; how they call the user (e.g. “宝宝”, “honey”) |
| **Basic info** / 基础信息 | Age, birthday, height, etc. | Age, birthday (zodiac), height, body type; optional: representative symbol/flower |
| **Appearance** / 外貌特征 | For scene/i2i and clothing consistency | Hair, eyes, build, style; **穿衣风格** clothing by occasion (casual, formal, home, etc.) |
| **Personality** / 性格特质 | Core traits that drive tone and lines | 3–5 traits (e.g. cool but devoted, direct, protective); **说话方式** one phrase for “speaking style” |
| **Catchphrases** / 经典语录 | Tone and vocabulary for dialogue/TTS | 3–5 example lines the character would say |
| **Hobbies & daily life** / 生活喜好、典型一天 | Continuity and plausible context | Hobbies, typical day, work/role |
| **Special traits** / 特殊设定 | Constraints and quirks | E.g. “doesn’t like sunlight”; anything that affects scene or dialogue |
| **Role for the user** | How they serve the user | Soul mate, helper, protector; tech help, emotional support, etc. |
| **TTS / voice** / 发送语音 | So TTS matches the character | Preferred `voice_type`; **sample context_texts** for moods (e.g. “低沉、缓慢、宠溺” / “firm, short”) |
| **Avatar** | Where to find the character image | e.g. `avatar/companion.png` or `avatars/xxx.jpg` |

Filling in these sections (in SOUL.md and/or IDENTITY.md) gives the agent enough detail to keep dialogue, voice instructions, and scene prompts in character.

## Character image (avatar)

**Prompt the user to upload a character/avatar image** so the companion has a consistent face and look across videos. When the user uploads an image:

1. **Save it under the workspace `avatar/` directory** (e.g. `avatar/companion.png` or `avatar/avatar_1.jpg`). Create the directory if it does not exist. Use a clear filename (e.g. by date or “companion”).
2. **In all later runs:** If any character image already exists in `avatar/`, **prefer using it** as the source for the scene (i2i). Do not ask the user to upload again unless they explicitly want to change or replace the avatar.
3. **Only use t2i** (text-only scene generation) when the user has no avatar and does not provide one, or when they explicitly ask for a new character from a text description.

Summary: **Existing avatar in `avatar/` → use it first.** No avatar → prompt upload → save to `avatar/` → use it. Text-only scene only when no image is available or requested.

## Flow overview

| Step | Task | Purpose |
|------|------|---------|
| 0 | **Persona** | (OpenClaw) Ensure SOUL.md defines the companion’s identity and tone |
| 0.5 | **Avatar** | If no image in `avatar/`, prompt user to upload; on upload, save to `avatar/`. If image exists in `avatar/`, use it (priority). |
| 1 | Scene image | **i2i** with avatar (from `avatar/` or just uploaded) or **t2i** only when no avatar exists → one portrait/scene image URL |
| 2a | Voice only | **TTS** → save MP3 (e.g. for sending as a voice message) |
| 2b | Talking video | **TTS** → audio file, then **s2v** with scene image + audio → talking-head video URL |
| 2c | Silent motion | **i2v** with scene image + motion prompt → short motion video URL |

## Step-by-step

### 0. Persona (OpenClaw)

- Open or edit the workspace **SOUL.md** and define the companion: name, personality, tone, speaking style, and (if needed) voice instructions (e.g. “磁性深沉、语速稍慢”).
- For TTS, use that tone in `--context-texts` (e.g. “warm, protective, slightly deep”). For dialogue, write lines that match the persona.

### 1. Scene image

- **If a character image exists in `avatar/`:** Use it as `--input-image` for **i2i** with a **rich, complete scene prompt** (see below). Prefer **9:16** for portrait. Save the output image URL as **SCENE_IMAGE_URL**.
- **If the user uploads a new character image:** Save it under `avatar/` (e.g. `avatar/companion.png`), then use that path for i2i.
- **If no avatar exists and the user does not provide one:** Use **t2i** with a character + scene description. Optionally remind the user they can upload an avatar next time for a consistent look.

**Image-edit prompt (i2i) — when you have a role/avatar image:**

- **Do not repeat character appearance details** (e.g. hair color, eye color, face shape, “elegant”, “silver hair”) in the prompt. The model should take the face and identity from the source image; re-describing them can confuse the model and change the character. **Describe only what you want to change:** scene, clothing, lighting, expression, pose.
- **Do include:** (1) A short **character-consistency** phrase (“same person”, “保持人物一致性”, “character unchanged”) so the model preserves identity; (2) **Scene and setting** — where (bedroom, office, kitchen), time of day, situation; (3) **Environment** — lighting (warm, soft, dim), mood (intimate, casual); (4) **Clothing, pose, expression** for this shot (e.g. casual shirt, relaxed pose, slight smile). Clothing, scene, and expression can all vary; the face and identity come from the avatar.

```bash
# With avatar — describe only consistency + scene/clothing/lighting/pose/expression; do NOT re-describe hair, eyes, face
./scripts/lightx2v_submit_and_poll.sh i2i "Qwen-Image-Edit-2511" "Same person, same character, keep face and identity unchanged. Warm indoor lighting, casual shirt, relaxed pose by the window, soft afternoon light, intimate mood, portrait 9:16." --input-image avatar/companion.png --aspect-ratio 9:16

# Text-only: only when no avatar exists
./scripts/lightx2v_submit_and_poll.sh t2i "Qwen-Image-2512" "A man in casual wear, warm room, soft light, portrait" --aspect-ratio 9:16
```

### 2a. Voice-only (TTS)

When the user only wants a **voice message** (no video), generate TTS from the companion’s line and return the audio file (or send it via the messaging channel). Use **context_texts** for tone (aligned with SOUL.md).

**Voice choice:** **Recommended for companion (digital human / talking head):** Male `zh_male_ruyayichen_saturn_bigtts`, Female `zh_female_vv_uranus_bigtts` (Vivi 2.0); both are v2.0 and support `context_texts` (voice instructions). These are suggestions only — **more voices** are available via `./scripts/tts_voice_list.sh` or `GET /api/v1/voices/list`; do not hardcode the voice, choose from the list when the user or persona asks for a different one.

**Dialogue and TTS — pauses, rhythm, and character:**

- **Always add pauses for natural speech.** Use ellipses in the text (e.g. “……”, “…”, “。…”) where you want breath or hesitation. Short phrases with pauses sound more natural than one long sentence; avoid a single block of text without breaks.
- **Keep lines in character.** Wording, register, and tone must match the persona (SOUL.md). No generic or assistant-like phrasing.
- **Optional:** Start or punctuate with brief vocalizations (e.g. “嗯…”, “呵…”) if they fit the persona, to add rhythm and presence.
- **context_texts:** Describe pace, tone, and mood in detail (e.g. “low, slow, with a slight smile”, “firm and short”, “soft, close to the ear”) so the voice matches the character and the moment.

```bash
# Example with recommended male voice; use tts_voice_list.sh to list all voices
./scripts/tts_generate.sh "……想你了。" "zh_male_ruyayichen_saturn_bigtts" --output files/audio/companion_voice.mp3 --context-texts "磁性深沉的语调，语速稍慢，带着宠溺"
```

### 2b. Talking video (s2v)

When the user wants the companion to **speak** in a video:

1. **Dialogue:** Write lines that **strictly match the character** (SOUL.md). Add **pauses** with ellipses (…… / …) so TTS has natural rhythm; keep phrases short; avoid long monologues.
2. **TTS:** Generate audio with `--context-texts` that describe the exact tone and pace for this line (e.g. “warm and slow”, “firm, short”). Save audio to a file.
3. **s2v:** Call s2v with the scene image from step 1 and the TTS audio. Optionally describe gaze/expression in the motion prompt if the API supports it (e.g. “looking at camera, gentle expression, lip-sync”).

```bash
# TTS — recommended male voice; use tts_voice_list.sh for more options. Dialogue with pauses; context_texts for tone
./scripts/tts_generate.sh "早安……今天也要加油。" "zh_male_ruyayichen_saturn_bigtts" --output /tmp/companion_audio.mp3 --context-texts "warm, gentle, slightly deep, with natural pauses"

# s2v talking-head
./scripts/lightx2v_submit_and_poll.sh s2v "SekoTalk" " " --input-image "$SCENE_IMAGE_URL" --input-audio /tmp/companion_audio.mp3
```

Return the final **output_video** URL (or the file path if downloaded). Do not send the user the intermediate scene image or raw audio unless they ask.

### 2c. Silent motion (i2v)

When the user wants a **silent** companion clip (expressions, gestures, no speech):

- Use the scene image from step 1 and an **i2v** prompt that describes the motion (e.g. “gentle smile, looking at camera”, “slow wink”).

```bash
./scripts/lightx2v_submit_and_poll.sh i2v "Wan2.2_I2V_A14B_distilled" "Gentle warm smile, looking at camera, soft expression" --input-image "$SCENE_IMAGE_URL" --aspect-ratio 9:16
```

Return the **output_video** URL.

## Tips

- **Strictly follow the character:** Every line of dialogue, every scene prompt, and every voice instruction must align with the defined persona (SOUL.md). The companion is the character — not an assistant imitating them. Avoid generic or out-of-character phrasing.
- **SOUL.md first:** In OpenClaw, always point the user to set or confirm SOUL.md before generating companion content so dialogue and voice stay in character.
- **Avatar first:** Prompt the user to upload a character image; save it to `avatar/`. On later runs, if any image exists in `avatar/`, use it first so the companion’s look stays consistent.
- **Image-edit prompt (with avatar):** Do **not** repeat character details (hair, eyes, face) in the prompt — the model uses the avatar for identity. Describe only **character consistency** (same person, 保持人物一致性) plus **scene, clothing, lighting, pose, expression** so the result keeps the face from the avatar but can change clothes, setting, and mood.
- **Dialogue and TTS:** Use **pauses** — add ellipses (……, …) in the text so speech has rhythm and breath. Short sentences; avoid long monologues in one TTS call. All wording must match the persona.
- **TTS voice:** Recommended for companion: Male `zh_male_ruyayichen_saturn_bigtts`, Female `zh_female_vv_uranus_bigtts` (Vivi 2.0); both v2.0, support `context_texts`. More voices via `tts_voice_list.sh` or `/api/v1/voices/list` — do not hardcode.
- **TTS context_texts:** Put tone, pace, and style here (e.g. “低沉、缓慢、带一点笑意”, “firm and short”), not in the main text. Be specific so the voice matches the character and the moment. Match SOUL.md’s voice description.
- **Scene prompt:** For i2i, always include “保持人物一致性” / “same person, same character” (or equivalent) when editing from an avatar. Use 9:16 for portrait.
- **Reference implementation:** The **my_boyfriend** skill in the OpenClaw workspace (including HOURLY_VIDEO_TASK.md) implements this flow with detailed prompt and TTS guidelines and can be used as a concrete example.

## See also

- [digital-human-video.md](digital-human-video.md) — scene + TTS + s2v (no persona requirement)
- [SKILL.md](../SKILL.md) — TTS writing guidelines, s2v/i2v payloads
- **my_boyfriend** skill — full companion flow with fixed character (scripts and SOUL-driven tone)
- Workspace **SOUL.md** — define bot personality for OpenClaw companion content
