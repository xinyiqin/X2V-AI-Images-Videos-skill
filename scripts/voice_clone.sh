#!/usr/bin/env bash
# LightX2V Voice Clone: upload audio to clone voice; prints speaker_id.
# Usage: voice_clone.sh /path/to/audio.wav [--text "optional transcript"]
# Env: LIGHTX2V_CLOUD_URL (default https://x2v.light-ai.top), LIGHTX2V_CLOUD_TOKEN (optional; required for cloud)

set -e

# Auto-load from openclaw.json when env not set
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

AUDIO_PATH="$1"
shift || true
USER_TEXT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --text) USER_TEXT="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$AUDIO_PATH" ] || [ ! -f "$AUDIO_PATH" ]; then
  echo "Usage: voice_clone.sh /path/to/audio.wav [--text \"transcript\"]" >&2
  exit 1
fi

RESP=$(curl -s -S -X POST "$BASE_URL/api/v1/voice/clone" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@$AUDIO_PATH" \
  ${USER_TEXT:+ -F "text=$USER_TEXT"})

if ! echo "$RESP" | grep -q '"speaker_id"'; then
  echo "Voice clone failed:" >&2
  echo "$RESP" >&2
  exit 1
fi

# Print speaker_id (simple extract)
echo "$RESP" | grep -o '"speaker_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:"\([^"]*\)".*/\1/'
