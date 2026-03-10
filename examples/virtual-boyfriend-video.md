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

**Image-edit prompt (i2i) — make it rich and stress character consistency:**

- Write a **full, specific** prompt. Do not use a single short phrase. Include:
  - **Character consistency:** Explicitly require “same person”, “same character”, “保持人物一致性”, “character unchanged” so the model keeps the face and identity from the avatar.
  - **Scene and setting:** Where (e.g. bedroom, office, kitchen, café), time of day, and situation (e.g. just woke up, working, resting).
  - **Environment:** Lighting (warm, soft, backlit, dim), mood (intimate, casual, formal), and a few concrete details (e.g. window light, desk, couch).
  - **Appearance in scene:** Clothing, pose, expression (e.g. casual shirt, relaxed pose, slight smile). Match the persona in SOUL.md.
  - **Optional:** One small “moment” or reaction (e.g. looking at camera, hand on table, leaning back) to make the frame feel alive.
- Keep style and tone consistent with the companion’s persona (e.g. elegant, casual, authoritative) so the image always feels like the same character.

```bash
# With avatar — use a rich prompt and stress character consistency
./scripts/lightx2v_submit_and_poll.sh i2i "Qwen-Image-Edit-2511" "Same person, same character, keep face and identity unchanged. Warm indoor lighting, casual shirt, relaxed pose by the window, soft afternoon light, intimate mood, portrait 9:16." --input-image avatar/companion.png --aspect-ratio 9:16

# Text-only: only when no avatar exists
./scripts/lightx2v_submit_and_poll.sh t2i "Qwen-Image-2512" "A man in casual wear, warm room, soft light, portrait" --aspect-ratio 9:16
```

### 2a. Voice-only (TTS)

When the user only wants a **voice message** (no video), generate TTS from the companion’s line and return the audio file (or send it via the messaging channel). Use **context_texts** for tone (aligned with SOUL.md).

**Dialogue and TTS — pauses, rhythm, and character:**

- **Always add pauses for natural speech.** Use ellipses in the text (e.g. “……”, “…”, “。…”) where you want breath or hesitation. Short phrases with pauses sound more natural than one long sentence; avoid a single block of text without breaks.
- **Keep lines in character.** Wording, register, and tone must match the persona (SOUL.md). No generic or assistant-like phrasing.
- **Optional:** Start or punctuate with brief vocalizations (e.g. “嗯…”, “呵…”) if they fit the persona, to add rhythm and presence.
- **context_texts:** Describe pace, tone, and mood in detail (e.g. “low, slow, with a slight smile”, “firm and short”, “soft, close to the ear”) so the voice matches the character and the moment.

```bash
./scripts/tts_generate.sh "……想你了。" "zh_male_ruyayichen_saturn_bigtts" --output files/audio/companion_voice.mp3 --context-texts "磁性深沉的语调，语速稍慢，带着宠溺"
```

### 2b. Talking video (s2v)

When the user wants the companion to **speak** in a video:

1. **Dialogue:** Write lines that **strictly match the character** (SOUL.md). Add **pauses** with ellipses (…… / …) so TTS has natural rhythm; keep phrases short; avoid long monologues.
2. **TTS:** Generate audio with `--context-texts` that describe the exact tone and pace for this line (e.g. “warm and slow”, “firm, short”). Save audio to a file.
3. **s2v:** Call s2v with the scene image from step 1 and the TTS audio. Optionally describe gaze/expression in the motion prompt if the API supports it (e.g. “looking at camera, gentle expression, lip-sync”).

```bash
# TTS — dialogue with pauses; context_texts for tone
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
- **Image-edit prompt:** Make the i2i prompt **rich and complete**. Always stress **character consistency** (same person, same face, 保持人物一致性). Include scene, setting, lighting, clothing, pose, and mood so the result looks like the same character in a clear situation.
- **Dialogue and TTS:** Use **pauses** — add ellipses (……, …) in the text so speech has rhythm and breath. Short sentences; avoid long monologues in one TTS call. All wording must match the persona.
- **TTS context_texts:** Put tone, pace, and style here (e.g. “低沉、缓慢、带一点笑意”, “firm and short”), not in the main text. Be specific so the voice matches the character and the moment. Match SOUL.md’s voice description.
- **Scene prompt:** For i2i, always include “保持人物一致性” / “same person, same character” (or equivalent) when editing from an avatar. Use 9:16 for portrait.
- **Reference implementation:** The **my_boyfriend** skill in the OpenClaw workspace (including HOURLY_VIDEO_TASK.md) implements this flow with detailed prompt and TTS guidelines and can be used as a concrete example.

## See also

- [digital-human-video.md](digital-human-video.md) — scene + TTS + s2v (no persona requirement)
- [SKILL.md](../SKILL.md) — TTS writing guidelines, s2v/i2v payloads
- **my_boyfriend** skill — full companion flow with fixed character (scripts and SOUL-driven tone)
- Workspace **SOUL.md** — define bot personality for OpenClaw companion content
