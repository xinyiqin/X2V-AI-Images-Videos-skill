# Complex case: Digital human (talking head) video

Generate a **talking-head video**: a character in a scene speaks a script with lip-sync. Use when the user asks for “数字人视频”, “digital human”, or “talking head” video with given or generated character/scene and a line to say.

## When to use

- User wants a video of a person (or character) speaking a given script.
- Inputs: (1) character/scene — **image** (user-provided) or **text description**; (2) **script** to speak; (3) optional scene/pose (e.g. office, casual, 9:16 portrait).
- Output: one video (no intermediate scene image or audio unless the user asks).

## Flow overview

| Step | Task | Purpose |
|------|------|---------|
| 1 | Scene image | **i2i** (if user gave an image) or **t2i** (if only text) → one portrait/scene image URL |
| 2 | Voice | **TTS** (or voice clone) → save audio to file (e.g. MP3) |
| 3 | Talking-head video | **s2v** with scene image + audio → output video URL |

## Step-by-step

### 1. Scene image

- **If user provided an image:** Use **i2i** with that image and a scene prompt (e.g. “Keep character consistent, same person in warm indoor lighting, portrait”). Prefer `aspect_ratio` **9:16** for talking head. Get `output_image` URL.
- **If user gave only text (no image):** Use **t2i** with a combined character + scene prompt. Get `output_image` URL.

Script examples:

```bash
# With user image (path or URL)
./scripts/lightx2v_submit_and_poll.sh i2i "Qwen-Image-Edit-2511" "Keep character consistent, same person in warm office lighting, portrait" --input-image /path/to/character.jpg --aspect-ratio 9:16

# Text-only: generate character + scene
./scripts/lightx2v_submit_and_poll.sh t2i "Qwen-Image-2512" "A woman in casual wear, warm room, soft light, portrait" --aspect-ratio 9:16
```

Save the printed URL as **SCENE_IMAGE_URL** (or keep the local path if you used one).

### 2. Voice (TTS)

- Choose a `voice_type` (and its `resource_id`) from the voice list. **Recommended for digital human:** Male `zh_male_ruyayichen_saturn_bigtts`, Female `zh_female_vv_uranus_bigtts` (Vivi 2.0); both are v2.0 and support `context_texts` (voice instructions). These are suggestions only — **more voices** are available via `./scripts/tts_voice_list.sh` or `GET /api/v1/voices/list`; do not hardcode, pick from the list when the user wants a different voice.
- Call **TTS** with the script text, `voice_type`, `resource_id`; optional `context_texts` (e.g. “warm, friendly”) for v2.0 voices. Write the response **directly to a file** (binary MP3); do not store in a shell variable.

```bash
# Example with recommended female voice (Vivi 2.0); use tts_voice_list.sh to see all options
./scripts/tts_generate.sh "Hello, this is a test of the digital human." "zh_female_vv_uranus_bigtts" --output /tmp/dh_audio.mp3
# Optional: --context-texts "warm and natural"
```

Use the saved audio path (e.g. `/tmp/dh_audio.mp3`) for step 3.

### 3. Digital human video (s2v)

- Call **s2v** with:
  - `input_image`: scene image from step 1 (URL or base64)
  - `input_audio`: audio from step 2 (base64 or path; script can convert path to base64)
  - `prompt`: short motion/description (e.g. “Natural talking head, lip-sync” or a space `" "` if not needed)
- Get `model_cls` for `task: "s2v"` from model list (e.g. `SekoTalk`). Poll until done; get `output_video` URL.

```bash
./scripts/lightx2v_submit_and_poll.sh s2v "SekoTalk" " " --input-image "$SCENE_IMAGE_URL" --input-audio /tmp/dh_audio.mp3
```

Return the final video URL (or download to `files/video/` and return the path). **Do not** send the user the intermediate scene image or audio file unless they ask.

## Tips

- **Scene prompt:** For i2i, include “保持人物一致性” / “keep character consistent” when editing a user image.
- **TTS / voice:** Recommended for digital human: Male `zh_male_ruyayichen_saturn_bigtts`, Female `zh_female_vv_uranus_bigtts` (Vivi 2.0); both v2.0, support `context_texts`. More voices via `tts_voice_list.sh` or `/api/v1/voices/list` — do not hardcode.
- **TTS:** Put only the spoken text in `text`; put tone/scene instructions in `context_texts` (v2.0 only). Use ellipses for pauses.
- **Aspect ratio:** 9:16 is typical for portrait talking head.
- **Large videos:** If the file is large, prefer returning the result **URL** instead of uploading the file (e.g. 16 MB message limit).

## See also

- **digital-human-video** skill: full workflow and output policy.
- LightX2V [SKILL.md](../SKILL.md): TTS writing guidelines, s2v payload, and binary response handling.
