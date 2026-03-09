# Complex case: One-sentence to video (image → video)

Turn a single sentence or idea into a short video: first get **one key image** (by text-to-image or from a user image + edit), then run **image-to-video** to animate it. Use when the user says “一句话生视频”, “turn this into a video”, or “animate this image/prompt”.

## When to use

- User gives a **text description** (e.g. “a cat on the beach at sunset”) or **one image** (e.g. “make this into a short video”).
- Goal: one short video that matches the description or the image, with motion (e.g. camera move, character motion).

## Flow overview

| Step | Task | Purpose |
|------|------|---------|
| 1 | Key image | **t2i** (no image) or **i2i** (user image + edit prompt) → one image URL |
| 2 | Video | **i2v** with that image + motion/camera prompt → output video URL |

## Step-by-step

### 1. Key image

- **If user provided an image:** Use **i2i** with that image and an edit prompt (style, scene, or “keep content, add cinematic lighting”). Get `output_image` URL.
- **If user gave only text:** Use **t2i** with that description (and optional style). Get `output_image` URL.

Script examples:

```bash
# Text only: one sentence → one image
./scripts/lightx2v_submit_and_poll.sh t2i "Qwen-Image-2512" "A cat sitting on the beach at sunset, waves in background" --aspect-ratio 16:9

# User image: edit then animate
./scripts/lightx2v_submit_and_poll.sh i2i "Qwen-Image-Edit-2511" "Same scene, golden hour lighting, keep character consistent" --input-image /path/to/user_image.png --aspect-ratio 16:9
```

Save the printed URL (or path) as the **key image** for step 2.

### 2. Image to video (i2v)

- Call **i2v** with:
  - `input_image`: key image from step 1 (URL or local path; script converts path to base64)
  - `prompt`: short motion/camera description (e.g. “Camera slowly pans right”, “Gentle breeze, leaves move slightly”)
- Get `model_cls` for `task: "i2v"` from model list (e.g. `Wan2.2_I2V_A14B_distilled`). Poll every 5–10 s; video can take a few minutes. Get `output_video` URL.

```bash
./scripts/lightx2v_submit_and_poll.sh i2v "Wan2.2_I2V_A14B_distilled" "Camera slowly pans right, gentle motion" --input-image "$KEY_IMAGE_URL"
```

Return the final video URL to the user. Optionally download to `files/video/` and return the path.

## Tips

- **Motion prompt:** Keep it short and clear (camera move, light change, small motion). Avoid long paragraphs.
- **Aspect ratio:** Use the same ratio for the key image and i2v (e.g. `16:9` or `9:16`).
- **Consistency:** If the user sent an image, the i2i prompt should preserve content and only adjust style/lighting if needed; then i2v adds motion.
- **Deliver only the video** unless the user asks for the intermediate image.

## See also

- **storyboard-video** skill: single-frame i2v flow (with or without user image).
- LightX2V [SKILL.md](../SKILL.md): task types, model list, and helper script usage.
