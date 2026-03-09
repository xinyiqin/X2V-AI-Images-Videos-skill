# OpenClaw LightX2V Skill

> [LightX2V](https://x2v.light-ai.top) integration for [OpenClaw](https://openclaw.ai) — image generation (t2i/i2i), video (t2v/i2v/s2v), TTS, and voice clone via cloud API.

## Features

- **Image** — Text-to-image (t2i), image editing (i2i)
- **Video** — Text-to-video (t2v), image-to-video (i2v), digital human / talking head (s2v)
- **TTS** — Text-to-speech with preset voices
- **Voice clone** — Clone voice from audio, then synthesize with the cloned voice

Use this skill for **cloud** API; for adult/restricted content or local inference, use **lightx2v-local** instead.

## Requirements

- [OpenClaw](https://openclaw.ai) installed and configured
- LightX2V cloud access token (from https://x2v.light-ai.top)

## Install

### Install from source (git + install.sh)

```bash
git clone https://github.com/xinyiqin/lightx2v_ai_generation_skills.git
cd lightx2v_ai_generation_skills
./install.sh
```

The installer will copy the skill to your OpenClaw workspace and prompt for your cloud token (optional at install time; you can set it later in `openclaw.json`).

## Configuration

Set in `~/.openclaw/openclaw.json` under `skills.entries.lightx2v.env` (or in the environment):

| Variable | Required | Description |
|----------|----------|-------------|
| `LIGHTX2V_CLOUD_TOKEN` | Yes | API token from https://x2v.light-ai.top |
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

Ensure `lightx2v` is in `skills.allow` if you use an allowlist.

## Usage

After installation, the OpenClaw agent can use the skill to:

- Generate or edit images from text or reference images
- Generate videos (t2v, i2v, digital human s2v)
- Generate speech (TTS) or clone a voice from an audio sample

All operations go through the cloud API; use **lightx2v-local** when you need local execution or content that may be restricted on the cloud.

## Uninstall

Remove the skill directory and the `lightx2v` entry from `openclaw.json`:

```bash
rm -rf ~/.openclaw/workspace/skills/lightx2v
# Then edit ~/.openclaw/openclaw.json to remove skills.entries.lightx2v and lightx2v from skills.allow
```
## License

MIT
