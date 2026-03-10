# 🎬 X2V-AI-Video-Skill — Free AI Image & Video Skill

**中文说明:** [README_zh.md](README_zh.md)

> **Free** AI image, video, TTS, and voice clone — use it for **full AI comic drama**, **AI MV**, **AI digital-human voiceover**, or deploy on [OpenClaw](https://openclaw.ai) as a **virtual boyfriend/girlfriend**. Powered by the open-source [LightX2V](https://github.com/ModelTC/LightX2V) free API; try the cloud at [x2v.light-ai.top](https://x2v.light-ai.top).  
> 👋 **Join our WeChat group! LightX2V Rotbot WeChat ID: `random42seed`**

## ✨ Features

- 🖼️ **Image** — Text-to-image (t2i), image editing (i2i)
- 🎞️ **Video** — Text-to-video (t2v), image-to-video (i2v), digital human / talking head (s2v), first–last frame (flf2v)
- 🎤 **TTS** — Text-to-speech with preset voices
- 🎙️ **Voice clone** — Clone a voice from audio, then synthesize with it
- 💕 **Virtual boyfriend/girlfriend (end-to-end complex case)** — Persona (SOUL.md) → avatar (`avatar/`) → scene image (i2i/t2i) → TTS/talking video (s2v) or silent motion (i2v); see [virtual-boyfriend-video.md](examples/virtual-boyfriend-video.md)

Use this skill for the **cloud** API. For restricted content or local unlimited inference, self-host by deploying models using [LightX2V](https://github.com/ModelTC/LightX2V) locally and running it as a service.

## 📋 Supported models (cloud)

Available via `GET /api/v1/model/list`. Use the `model_cls` value when submitting tasks:

| Task | model_cls |
|------|-----------|
| **t2i** (text-to-image) | `Qwen-Image-Edit-2509`, `Qwen-Image-2512` |
| **i2i** (image edit) | `Qwen-Image-Edit-2509`, `Qwen-Image-Edit-2511` |
| **t2v** (text-to-video) | `Wan2.2_T2V_A14B_distilled` |
| **i2v** (image-to-video) | `Wan2.2_I2V_A14B_distilled` |
| **s2v** (digital human) | `SekoTalk` |
| **flf2v** (first-last frame) | `Wan2.2_I2V_A14B_distilled` |
| **animate** | `wan2.2_animate` |

TTS and voice clone use separate endpoints (see SKILL.md); no `model_cls` needed.

## 📌 Requirements

- [OpenClaw](https://openclaw.ai) installed and configured
- LightX2V cloud access token — **how to get it:** [Get token (Feishu doc)](https://pgzodr3heu.feishu.cn/wiki/LuYOwNkrMiXEGLkqbHXcahBonhg?from=from_copylink) \| [x2v.light-ai.top](https://x2v.light-ai.top)
- Free tier: 100 task submissions per day

## 🚀 Install

### Install from source (git + install.sh)

```bash
git clone https://github.com/xinyiqin/lightx2v_ai_generation_skills.git
cd lightx2v_ai_generation_skills
./install.sh
```

The installer will copy the skill to your OpenClaw workspace and prompt for your cloud token (optional at install time; you can set it later in `openclaw.json`).

## ⚙️ Configuration

Set in `~/.openclaw/openclaw.json` under `skills.entries.lightx2v.env` (or in the environment):

| Variable | Required | Description |
|----------|----------|-------------|
| `LIGHTX2V_CLOUD_TOKEN` | Yes | API token — see [how to get token (Feishu)](https://pgzodr3heu.feishu.cn/wiki/LuYOwNkrMiXEGLkqbHXcahBonhg?from=from_copylink) |
| `LIGHTX2V_CLOUD_URL` | No | Base URL (default: `https://x2v.light-ai.top`) |

Example:

```json
"skills": {
  "entries": {
    "lightx2v": {
      "enabled": true,
      "env": {
        "LIGHTX2V_CLOUD_TOKEN": "your-token",
        "LIGHTX2V_CLOUD_URL": "https://x2v.light-ai.top"
      }
    }
  }
}
```

**Auto-load:** The scripts (e.g. `lightx2v_submit_and_poll.sh`, `tts_generate.sh`) read `LIGHTX2V_CLOUD_TOKEN` and `LIGHTX2V_CLOUD_URL` from `~/.openclaw/openclaw.json` when they are not already set in the environment, so you do not need to `export` them in the shell every time. Configure once in openclaw.json and run the scripts directly.

Ensure `lightx2v` is in `skills.allow` if you use an allowlist.

## 💡 Usage

After installation, the OpenClaw agent can use the skill to:

- Generate or edit images from text or reference images
- Generate videos (t2v, i2v, digital human s2v)
- Generate speech (TTS) or clone a voice from an audio sample

## 📚 Complex case examples

Step-by-step guides for multi-step workflows (e.g. digital-human-video, storyboard-video, my_boyfriend):

| Example | Description | Doc |
|--------|-------------|-----|
| 🎞️ **First–last frame (flf2v)** | First frame (t2i or user image) → i2i last frame → flf2v → short transition video | [first-last-frame-video.md](examples/first-last-frame-video.md) |
| 🎬 **Digital human video** | Scene image + TTS → s2v → talking-head video | [digital-human-video.md](examples/digital-human-video.md) |
| 🎥 **One-sentence to video** | t2i/i2i → one key image → i2v → short video | [one-sentence-to-video.md](examples/one-sentence-to-video.md) |
| 💕 **Virtual boyfriend/girlfriend** | Persona (SOUL.md) → scene image + TTS/s2v or i2v → companion video or voice; *OpenClaw: set bot personality first* | [virtual-boyfriend-video.md](examples/virtual-boyfriend-video.md) |

## 🗑️ Uninstall

Remove the skill directory and the `lightx2v` entry from `openclaw.json`:

```bash
rm -rf ~/.openclaw/workspace/skills/lightx2v
# Then edit ~/.openclaw/openclaw.json to remove skills.entries.lightx2v and lightx2v from skills.allow
```
## 📄 License

MIT
