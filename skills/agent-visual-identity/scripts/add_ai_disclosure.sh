#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  add_ai_disclosure.sh INPUT.mp4 OUTPUT.mp4 [watermark text]

Environment variables:
  WATERMARK_TEXT       Visible watermark; default: AI GENERATED
  FONT_FILE            Font path; default: first available DejaVu Sans font
  WATERMARK_FONTSIZE   Font size in output pixels; default: 28
  WATERMARK_ALPHA      Text alpha; default: 0.88
  BOX_ALPHA            Background box alpha; default: 0.42
  MARGIN_X             Right margin in output pixels; default: 24
  MARGIN_Y             Bottom margin in output pixels; default: 24
  VIDEO_CRF            libx264 CRF; default: 18
  VIDEO_PRESET         libx264 preset; default: medium
  AI_MODEL             Metadata model name; default: MiniMax H3
  HUMAN_DIRECTION      Metadata human direction; default: Yang
EOF
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage >&2
  exit 2
fi

INPUT=$1
OUTPUT=$2
WATERMARK_TEXT=${3:-${WATERMARK_TEXT:-AI GENERATED}}

[[ -f "$INPUT" ]] || { echo "Input does not exist: $INPUT" >&2; exit 1; }
[[ "$INPUT" != "$OUTPUT" ]] || { echo "Input and output must be different files" >&2; exit 1; }
command -v ffmpeg >/dev/null || { echo "ffmpeg is required" >&2; exit 1; }
command -v ffprobe >/dev/null || { echo "ffprobe is required" >&2; exit 1; }

FONT_FILE=${FONT_FILE:-}
if [[ -z "$FONT_FILE" ]]; then
  for candidate in \
    /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf \
    /usr/share/fonts/truetype/liberation2/LiberationSans-Regular.ttf \
    /usr/share/fonts/opentype/noto/NotoSansCJKsc-Light.otf; do
    if [[ -f "$candidate" ]]; then FONT_FILE=$candidate; break; fi
  done
fi
[[ -n "$FONT_FILE" && -f "$FONT_FILE" ]] || { echo "No usable font found; set FONT_FILE" >&2; exit 1; }

WATERMARK_FONTSIZE=${WATERMARK_FONTSIZE:-28}
WATERMARK_ALPHA=${WATERMARK_ALPHA:-0.88}
BOX_ALPHA=${BOX_ALPHA:-0.42}
MARGIN_X=${MARGIN_X:-24}
MARGIN_Y=${MARGIN_Y:-24}
VIDEO_CRF=${VIDEO_CRF:-18}
VIDEO_PRESET=${VIDEO_PRESET:-medium}
AI_MODEL=${AI_MODEL:-MiniMax H3}
HUMAN_DIRECTION=${HUMAN_DIRECTION:-Yang}

mkdir -p "$(dirname "$OUTPUT")"
TMP_TEXT=$(mktemp)
TMP_OUTPUT="${OUTPUT}.tmp.$$.$RANDOM.mp4"
cleanup() { rm -f "$TMP_TEXT" "$TMP_OUTPUT"; }
trap cleanup EXIT
printf '%s' "$WATERMARK_TEXT" > "$TMP_TEXT"

# Escape values used inside FFmpeg's filter expression.
escape_filter_value() {
  printf '%s' "$1" | sed "s/\\\\/\\\\\\\\/g; s/:/\\\\:/g; s/'/\\\\'/g"
}
FONT_ESC=$(escape_filter_value "$FONT_FILE")
TEXT_ESC=$(escape_filter_value "$TMP_TEXT")

# Layer pipeline:
#   [0:v] -> visible AI disclosure layer -> [vout]
#   [0:a]? -> optional original audio -> encoded AAC output
FILTER="drawtext=fontfile='${FONT_ESC}':textfile='${TEXT_ESC}':reload=0:fontsize=${WATERMARK_FONTSIZE}:fontcolor=white@${WATERMARK_ALPHA}:box=1:boxcolor=black@${BOX_ALPHA}:boxborderw=10:x=w-tw-${MARGIN_X}:y=h-th-${MARGIN_Y}"

ffmpeg -hide_banner -y -i "$INPUT" \
  -filter_complex "[0:v]${FILTER}[vout]" \
  -map "[vout]" -map 0:a? \
  -c:v libx264 -preset "$VIDEO_PRESET" -crf "$VIDEO_CRF" -pix_fmt yuv420p \
  -c:a aac -b:a 192k \
  -movflags +faststart \
  -metadata title='AI-generated video' \
  -metadata artist='Agents打工日记' \
  -metadata comment='AI GENERATED / AI-assisted creation; fictional characters, scenes, actions, and sound; human-directed.' \
  -metadata description='This video was generated with AI and human direction. Characters, scenes, actions, and sound are fictional and do not represent a real event.' \
  -metadata ai_generated=true \
  -metadata ai_assisted=true \
  -metadata ai_model="$AI_MODEL" \
  -metadata human_direction="$HUMAN_DIRECTION" \
  "$TMP_OUTPUT"

[[ -s "$TMP_OUTPUT" ]] || { echo "FFmpeg produced no output" >&2; exit 1; }
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,r_frame_rate -of default=noprint_wrappers=1 "$TMP_OUTPUT"
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1 "$TMP_OUTPUT"

mv -f "$TMP_OUTPUT" "$OUTPUT"
trap - EXIT
rm -f "$TMP_TEXT"
echo "Wrote: $OUTPUT"
