#!/usr/bin/env bash
# LightX2V TTS: list preset voices. Prints voice_type and resource_id for use with tts_generate.sh.
# Usage: tts_voice_list.sh [--version VERSION]
# Env: LIGHTX2V_CLOUD_URL (default https://x2v.light-ai.top), LIGHTX2V_CLOUD_TOKEN (optional)

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

VERSION=""
while [ $# -gt 0 ]; do
  case "$1" in
    --version) VERSION="$2"; shift 2 ;;
    *) echo "Usage: tts_voice_list.sh [--version VERSION]" >&2; exit 1 ;;
  esac
done

URL="$BASE_URL/api/v1/voices/list"
[ -n "$VERSION" ] && URL="${URL}?version=$VERSION"

RESPONSE=$(curl -s "${CURL_AUTH[@]}" "$URL")
if ! echo "$RESPONSE" | grep -q '"voices"'; then
  echo "Failed to get voice list:" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  echo "$RESPONSE" | jq -r '.voices[]? | "\(.voice_type // .voiceType // "?") \(.resource_id // .resourceId // "")"' 2>/dev/null || echo "$RESPONSE" | jq .
else
  echo "$RESPONSE" | grep -o '"voice_type":"[^"]*"[^}]*"resource_id":"[^"]*"' | sed 's/"voice_type":"\([^"]*\)".*"resource_id":"\([^"]*\)"/\1 \2/'
fi
