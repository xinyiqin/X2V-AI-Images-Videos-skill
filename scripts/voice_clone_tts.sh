  #!/usr/bin/env bash
  # LightX2V Voice Clone TTS: synthesize speech with a cloned voice. Saves WAV to --output.
  # Usage: voice_clone_tts.sh <speaker_id> "text" [--output out.wav] [--style 正常] [--speed 1.0]
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

  SPEAKER_ID="$1"
  TEXT="$2"
  shift 2 || true
  OUTPUT="voice_clone_tts.wav"
  STYLE="正常"
  SPEED="1.0"
  VOLUME="0"
  PITCH="0"
  LANG="ZH_CN"

  while [ $# -gt 0 ]; do
    case "$1" in
      --output) OUTPUT="$2"; shift 2 ;;
      --style)  STYLE="$2";  shift 2 ;;
      --speed)  SPEED="$2";  shift 2 ;;
      --volume) VOLUME="$2"; shift 2 ;;
      --pitch)  PITCH="$2";  shift 2 ;;
      --language) LANG="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  if [ -z "$SPEAKER_ID" ] || [ -z "$TEXT" ]; then
    echo "Usage: voice_clone_tts.sh <speaker_id> \"text\" [--output out.wav] [--style 正常] [--speed 1.0]" >&2
    exit 1
  fi

  escape_json() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g; s/$/\\n/' | tr -d '\n'; }
  TEXT_ESC=$(escape_json "$TEXT")
  TEXT_ESC="${TEXT_ESC%\\n}"
  STYLE_ESC=$(escape_json "$STYLE")
  STYLE_ESC="${STYLE_ESC%\\n}"

  BODY="{\"text\":\"$TEXT_ESC\",\"speaker_id\":\"$SPEAKER_ID\",\"style\":\"$STYLE_ESC\",\"speed\":$SPEED,\"volume\":$VOLUME,\"pitch\":$PITCH,\"language\":\"$LANG\"}"

  HTTP=$(curl -s -w "%{http_code}" -o "$OUTPUT" -X POST "$BASE_URL/api/v1/voice/clone/tts" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$BODY")

  if [ "$HTTP" != "200" ]; then
    echo "Voice clone TTS failed (HTTP $HTTP). Response:" >&2
    cat "$OUTPUT" >&2
    exit 1
  fi

  # If response looks like JSON (error), fail
  if head -c1 "$OUTPUT" | grep -q '{'; then
    echo "Voice clone TTS failed (server returned JSON error):" >&2
    cat "$OUTPUT" >&2
    exit 1
  fi

  echo "$OUTPUT"
