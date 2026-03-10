# 🎬 X2V-AI-Video-Skill — 免费 AI 图像与视频 Skill

**English:** [README.md](README.md)

> **免费** AI 图像、视频、TTS 与语音克隆 — 可用来做 **完整 AI 漫剧**、**AI MV**、**AI 数字人口播**，或部署到 [OpenClaw](https://openclaw.ai) 上当 **虚拟男友/女友**。基于开源 [LightX2V](https://github.com/ModelTC/LightX2V) 的免费 API，云端即用：[x2v.light-ai.top](https://x2v.light-ai.top)。
> 👋 加入我们的微信群！LightX2V 机器人微信号：random42seed

## ✨ 功能

- 🖼️ **图像** — 文生图 (t2i)、图像编辑 (i2i)
- 🎞️ **视频** — 文生视频 (t2v)、图生视频 (i2v)、数字人/口播 (s2v)、首尾帧视频 (flf2v)
- 🎤 **TTS** — 预设音色文本转语音
- 🎙️ **语音克隆** — 从音频克隆声音，再用该声音合成
- 💕 **虚拟男友/女友（端到端复杂案例）** — 人设 (SOUL.md) → 角色图 (avatar/) → 场景图 (i2i/t2i) → TTS/口播 (s2v) 或无声动作 (i2v)，见 [virtual-boyfriend-video.md](examples/virtual-boyfriend-video.md)

本技能使用**LightX2V 云端** API。需要更多模型或本地推理请自行通过LightX2V框架部署 [LightX2V](https://github.com/ModelTC/LightX2V) 并起服务后使用。

## 📋 支持的模型（云端）

通过 `GET /api/v1/model/list` 获取。提交任务时使用返回的 `model_cls`：

| 任务 | model_cls |
|------|-----------|
| **t2i**（文生图） | `Qwen-Image-Edit-2509`、`Qwen-Image-2512` |
| **i2i**（图像编辑） | `Qwen-Image-Edit-2509`、`Qwen-Image-Edit-2511` |
| **t2v**（文生视频） | `Wan2.2_T2V_A14B_distilled` |
| **i2v**（图生视频） | `Wan2.2_I2V_A14B_distilled` |
| **s2v**（数字人） | `SekoTalk` |
| **flf2v**（首尾帧） | `Wan2.2_I2V_A14B_distilled` |
| **animate** | `wan2.2_animate` |

TTS 与语音克隆走独立接口（见 SKILL.md），无需 `model_cls`。

## 📌 要求

- 已安装并配置 [OpenClaw](https://openclaw.ai)
- LightX2V 云端 token — **获取方式：** [获取 Token 说明（飞书文档）](https://pgzodr3heu.feishu.cn/wiki/LuYOwNkrMiXEGLkqbHXcahBonhg?from=from_copylink) \| [x2v.light-ai.top](https://x2v.light-ai.top)
- 免费额度：每日 100 次任务提交

## 🚀 安装

### 从源码安装（git + install.sh）

```bash
git clone https://github.com/xinyiqin/lightx2v_ai_generation_skills.git
cd lightx2v_ai_generation_skills
./install.sh
```

安装程序会把技能复制到 OpenClaw 工作区，并可选在安装时填写云端 token（也可稍后在 `openclaw.json` 中配置）。

## ⚙️ 配置

在 `~/.openclaw/openclaw.json` 的 `skills.entries.lightx2v.env` 下配置（或使用环境变量）：

| 变量 | 必填 | 说明 |
|------|------|------|
| `LIGHTX2V_CLOUD_TOKEN` | 是 | API token，获取方式见 [获取 Token 说明（飞书）](https://pgzodr3heu.feishu.cn/wiki/LuYOwNkrMiXEGLkqbHXcahBonhg?from=from_copylink) |
| `LIGHTX2V_CLOUD_URL` | 否 | 接口地址（默认 `https://x2v.light-ai.top`） |

示例：

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

**自动读取：** 脚本（如 `lightx2v_submit_and_poll.sh`、`tts_generate.sh`）在环境未设置时会从 `~/.openclaw/openclaw.json` 读取上述变量，无需每次在 shell 里 `export`，配置一次即可直接运行脚本。

若使用 allowlist，请将 `lightx2v` 加入 `skills.allow`。

## 💡 使用

安装后，OpenClaw 中的 agent 可调用本技能：

- 根据文本或参考图生成、编辑图像
- 生成视频（t2v、i2v、数字人 s2v）
- 合成语音（TTS）或从音频克隆声音后合成

## 📚 复杂案例示例

多步流程的步骤说明：

| 示例 | 说明 | 文档 |
|------|------|------|
| 🎞️ **首尾帧视频 (flf2v)** | 首帧（t2i 或用户图）→ i2i 尾帧 → flf2v → 短视频 | [first-last-frame-video.md](examples/first-last-frame-video.md) |
| 🎬 **数字人视频** | 场景图 + TTS → s2v → 口播视频 | [digital-human-video.md](examples/digital-human-video.md) |
| 🎥 **一句话生视频** | t2i/i2i → 一张关键图 → i2v → 短视频 | [one-sentence-to-video.md](examples/one-sentence-to-video.md) |
| 💕 **虚拟男友/女友** | 人设 (SOUL.md) → 场景图 + TTS/s2v 或 i2v → 伴侣视频/语音；*OpenClaw 用户请先设定 bot 人格* | [virtual-boyfriend-video.md](examples/virtual-boyfriend-video.md) |

## 🗑️ 卸载

删除技能目录并从 `openclaw.json` 中移除 `lightx2v` 配置：

```bash
rm -rf ~/.openclaw/workspace/skills/lightx2v
# 并编辑 ~/.openclaw/openclaw.json，删除 skills.entries.lightx2v 及 skills.allow 中的 lightx2v
```

## 📄 许可证

MIT
