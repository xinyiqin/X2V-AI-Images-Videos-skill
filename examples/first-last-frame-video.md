# Complex case: First–last frame video (flf2v)

Generate a short video (~5 s) that transitions from a **first frame** to a **last frame**. The model interpolates between the two frames. Use when the user asks for “首尾帧视频”, “first-last frame video”, or a short transition between two keyframes.

## When to use

- User wants a video that goes from one keyframe to another (e.g. camera push, time lapse, slight motion).
- The transition should be short (~5 s); keep the change between first and last frame **moderate** (same scene/character, avoid full scene or character change).

## Flow overview

| Step | Task | Purpose |
|------|------|---------|
| 1 | Get first frame | **t2i** (if no image) or use **given image** as first frame |
| 2 | Get last frame | **i2i** on first frame with a “last frame” edit prompt (small change: camera move, light change, small motion) |
| 3 | Generate video | **flf2v** with first-frame and last-frame images → output video URL |

## Step-by-step

### 1. First frame

- **If user provides an image:** Use that image as the first frame (local path or URL). You will pass it to i2i and then to flf2v.
- **If no image:** Call **t2i** with a scene/character prompt and desired `aspect_ratio` (e.g. `9:16`). Poll until done; get `output_image` URL → this is the **first frame URL**.

Example (script, no image):

```bash
# From skill dir; token/URL auto-loaded from openclaw.json if not set
./scripts/lightx2v_submit_and_poll.sh t2i "Qwen-Image-2512" "A person standing in a room, soft window light" --aspect-ratio 9:16
# → Save the printed URL as FIRST_FRAME_URL
```

### 2. Last frame (i2i on first frame)

- Call **i2i** with:
  - `input_image`: first frame (URL from step 1 or base64 from user image)
  - `prompt`: edit that describes a **small** change (e.g. “Same scene, same character. Slight camera push-in; light shifts slightly as if 5 seconds passed.”). Avoid changing scene or character.
- Poll until done; get `output_image` URL → this is the **last frame URL**.

Example (script, first frame as URL):

```bash
./scripts/lightx2v_submit_and_poll.sh i2i "Qwen-Image-Edit-2511" "Same scene and character. Slight camera push-in, soft light change, 5 second transition." --input-image "$FIRST_FRAME_URL" --aspect-ratio 9:16
# → Save the printed URL as LAST_FRAME_URL
```

### 3. flf2v (first–last frame to video)

- Call **flf2v** with first-frame image (`input_image`) and last-frame image (`input_last_frame`). Use the same submit script with `--input-image <first_frame_url>` and `--input-last-frame <last_frame_url>`.
- Poll until done; the script prints the `output_video` URL.

Example (after you have `FIRST_FRAME_URL` and `LAST_FRAME_URL` from steps 1 and 2):

```bash
./scripts/lightx2v_submit_and_poll.sh flf2v "Wan2.2_I2V_A14B_distilled" " " \
  --input-image "$FIRST_FRAME_URL" --input-last-frame "$LAST_FRAME_URL" --aspect-ratio 9:16
# → Prints the final video URL
```

So the full flow is: **t2i** (or user image) → **i2i** → **flf2v**, all with the same script; no extra curl or custom script needed.

## Tips

- **Keep the change small:** Same location and character; only camera, lighting, or small motion change so the ~5 s interpolation looks natural.
- **Prompt for i2i:** Include “保持人物一致性” / “same character, same scene” when there is a character; describe only the small difference for the last frame.
- **Aspect ratio:** Use the same ratio for t2i, i2i, and flf2v (e.g. `9:16` for portrait).
- **Deliver only the final video** to the user; do not send intermediate first/last frame images unless asked.

## See also

- **storyboard-video** skill: flf2v flow with S3 and `generate_flf2v_shot.sh`.
- LightX2V [SKILL.md](../SKILL.md): task types, model list, and submit/poll workflow.
