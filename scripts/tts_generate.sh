#!/usr/bin/env bash
# LightX2V TTS: generate speech from text with preset voice. Saves MP3 to --output.
# Usage: tts_generate.sh "text" "voice_type" [--output out.mp3] [--context-texts "语气指令"] [--emotion "情绪"] [--emotion-scale N] [--speech-rate N] [--loudness-rate N] [--pitch N]
# Env: LIGHTX2V_CLOUD_URL (default https://x2v.light-ai.top), LIGHTX2V_CLOUD_TOKEN (optional; empty for local no-auth)

set -e

# Auto-load from openclaw.json when env not set (avoids re-typing token every time)
if [ -z "${LIGHTX2V_CLOUD_TOKEN}" ]; then
  OPENCLAW_CFG="${OPENCLAW_CONFIG:-$HOME/.openclaw/openclaw.json}"
  if [ -f "$OPENCLAW_CFG" ]; then
    if command -v jq &>/dev/null; then
      export LIGHTX2V_CLOUD_TOKEN=$(jq -r '.skills.entries["lightx2v"].env.LIGHTX2V_CLOUD_TOKEN // empty' "$OPENCLAW_CFG")
      _url=$(jq -r '.skills.entries["lightx2v"].env.LIGHTX2V_CLOUD_URL // empty' "$OPENCLAW_CFG")
      [ -n "$_url" ] && export LIGHTX2V_CLOUD_URL="$_url"
    else
      export LIGHTX2V_CLOUD_TOKEN=$(python3 -c "
import json,sys
try:
    with open(sys.argv[1]) as f: d=json.load(f)
    e=d.get('skills',{}).get('entries',{}).get('lightx2v',{}).get('env',{})
    print(e.get('LIGHTX2V_CLOUD_TOKEN','') or '')
except Exception: pass
" "$OPENCLAW_CFG")
      _url=$(python3 -c "
import json,sys
try:
    with open(sys.argv[1]) as f: d=json.load(f)
    e=d.get('skills',{}).get('entries',{}).get('lightx2v',{}).get('env',{})
    print(e.get('LIGHTX2V_CLOUD_URL','') or '')
except Exception: pass
" "$OPENCLAW_CFG")
      [ -n "$_url" ] && export LIGHTX2V_CLOUD_URL="$_url"
    fi
  fi
fi

BASE_URL="${LIGHTX2V_CLOUD_URL:-https://x2v.light-ai.top}"
BASE_URL="${BASE_URL%/}"
TOKEN="${LIGHTX2V_CLOUD_TOKEN:-}"
CURL_AUTH=(); [ -n "$TOKEN" ] && CURL_AUTH=(-H "Authorization: Bearer $TOKEN")

TEXT="$1"
VOICE_TYPE="$2"
shift 2 || true

# Optional params (API defaults)
OUTPUT=""
CONTEXT_TEXTS=""
EMOTION=""
EMOTION_SCALE="3"
SPEECH_RATE="0"
LOUDNESS_RATE="0"
PITCH="0"

while [ $# -gt 0 ]; do
  case "$1" in
    --output)         OUTPUT="$2"; shift 2 ;;
    --context-texts)  CONTEXT_TEXTS="$2"; shift 2 ;;
    --emotion)        EMOTION="$2"; shift 2 ;;
    --emotion-scale)  EMOTION_SCALE="$2"; shift 2 ;;
    --speech-rate)    SPEECH_RATE="$2"; shift 2 ;;
    --loudness-rate)  LOUDNESS_RATE="$2"; shift 2 ;;
    --pitch)          PITCH="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$TEXT" ] || [ -z "$VOICE_TYPE" ]; then
  echo "Usage: tts_generate.sh \"text\" \"voice_type\" [--output out.mp3] [--context-texts \"语气/上下文指令\"] [--emotion \"情绪\"] [--emotion-scale N] [--speech-rate N] [--loudness-rate N] [--pitch N]" >&2
  exit 1
fi

[ -z "$OUTPUT" ] && OUTPUT="tts_output_$(date +%s).mp3"

# Get voice list and extract resource_id for the specified voice_type
echo "🔍 获取语音配置..."
VOICES_RESPONSE=$(curl -s "${CURL_AUTH[@]}" "$BASE_URL/api/v1/voices/list")
if [ $? -ne 0 ]; then
  echo "❌ 获取语音列表失败" >&2
  exit 1
fi

RESOURCE_ID=$(echo "$VOICES_RESPONSE" | grep -o "\"voice_type\":\"$VOICE_TYPE\"[^}]*\"resource_id\":\"[^\"]*\"" | grep -o "\"resource_id\":\"[^\"]*\"" | cut -d'"' -f4)

if [ -z "$RESOURCE_ID" ]; then
  echo "❌ 未找到语音类型 '$VOICE_TYPE' 的 resource_id" >&2
  echo "💡 可用的语音类型，请检查拼写：" >&2
  echo "$VOICES_RESPONSE" | grep -o "\"voice_type\":\"[^\"]*\"" | cut -d'"' -f4 | head -10 >&2
  exit 1
fi

echo "✅ 找到 resource_id: $RESOURCE_ID"

# Escape for JSON: backslash and double-quote
escape_json() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g; s/$/\\n/' | tr -d '\n'; }
TEXT_ESC=$(escape_json "$TEXT")
TEXT_ESC="${TEXT_ESC%\\n}"
VOICE_ESC=$(escape_json "$VOICE_TYPE")
VOICE_ESC="${VOICE_ESC%\\n}"
CTX_ESC=$(escape_json "$CONTEXT_TEXTS")
CTX_ESC="${CTX_ESC%\\n}"
EMO_ESC=$(escape_json "$EMOTION")
EMO_ESC="${EMO_ESC%\\n}"

BODY="{\"text\":\"$TEXT_ESC\",\"voice_type\":\"$VOICE_ESC\",\"context_texts\":\"$CTX_ESC\",\"emotion\":\"$EMO_ESC\",\"emotion_scale\":${EMOTION_SCALE},\"speech_rate\":${SPEECH_RATE},\"pitch\":${PITCH},\"loudness_rate\":${LOUDNESS_RATE},\"resource_id\":\"$RESOURCE_ID\"}"

echo "🎤 生成TTS音频..."
HTTP=$(curl -s -w "%{http_code}" -o "$OUTPUT" -X POST "$BASE_URL/api/v1/tts/generate" \
  "${CURL_AUTH[@]}" \
  -H "Content-Type: application/json" \
  -d "$BODY")

if [ "$HTTP" != "200" ]; then
  echo "TTS request failed (HTTP $HTTP). Response body:" >&2
  cat "$OUTPUT" >&2
  exit 1
fi

# Check if response is JSON error (not binary mp3)
if head -c1 "$OUTPUT" | grep -q '{'; then
  echo "TTS failed (server returned JSON error):" >&2
  cat "$OUTPUT" >&2
  exit 1
fi

echo "✅ TTS 生成成功: $OUTPUT"
echo "$OUTPUT"
