#!/usr/bin/env bash
# LightX2V Voice Clone: list user's cloned voices. Prints speaker_id and name for use with voice_clone_tts.sh.
# Usage: voice_clone_list.sh
# Env: LIGHTX2V_CLOUD_URL (default https://x2v.light-ai.top), LIGHTX2V_CLOUD_TOKEN (required for cloud)

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

URL="$BASE_URL/api/v1/voice/clone/list"
RESPONSE=$(curl -s "${CURL_AUTH[@]}" "$URL")

if ! echo "$RESPONSE" | grep -q '"voice_clones"'; then
  echo "Failed to get voice clone list:" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  echo "$RESPONSE" | jq -r '.voice_clones[]? | "\(.speaker_id // .speakerId // "?") \(.name // "")"' 2>/dev/null || echo "$RESPONSE" | jq .
else
  echo "$RESPONSE" | grep -o '"speaker_id":"[^"]*"[^}]*"name":"[^"]*"' | sed 's/"speaker_id":"\([^"]*\)".*"name":"\([^"]*\)"/\1 \2/' || echo "$RESPONSE"
fi
