#!/usr/bin/env bash
# Resize screenshots to App Store iPhone 6.5" sizes (keeps aspect ratio, letterboxes if needed).
# Requires: ffmpeg (brew install ffmpeg)
#
# Usage:
#   ./tools/resize_appstore_iphone_screenshots.sh <input_dir> <output_dir> [size_key]
#
# size_key:
#   1242x2688   — portrait 1242×2688 (default)
#   2688x1242   — landscape
#   1284x2778   — portrait 1284×2778
#   2778x1284   — landscape
#
# Example:
#   ./tools/resize_appstore_iphone_screenshots.sh ~/Desktop/raw ~/Desktop/out 1242x2688

set -euo pipefail

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "Install ffmpeg first: brew install ffmpeg" >&2
  exit 1
fi

INPUT_DIR="${1:-}"
OUTPUT_DIR="${2:-}"
SIZE_KEY="${3:-1242x2688}"

if [[ -z "$INPUT_DIR" || -z "$OUTPUT_DIR" ]]; then
  echo "Usage: $0 <input_dir> <output_dir> [size_key]" >&2
  exit 1
fi

case "$SIZE_KEY" in
  1242x2688) W=1242; H=2688 ;;
  2688x1242) W=2688; H=1242 ;;
  1284x2778) W=1284; H=2778 ;;
  2778x1284) W=2778; H=1284 ;;
  *)
    echo "Unknown size_key: $SIZE_KEY (use 1242x2688, 2688x1242, 1284x2778, or 2778x1284)" >&2
    exit 1
    ;;
esac

mkdir -p "$OUTPUT_DIR"

shopt -s nullglob
files=("$INPUT_DIR"/*.{png,jpg,jpeg,PNG,JPG,JPEG})
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No png/jpg found in: $INPUT_DIR" >&2
  exit 1
fi

for f in "${files[@]}"; do
  base=$(basename "$f")
  name="${base%.*}"
  ext="${base##*.}"
  out_ext=$( [[ "${ext,,}" == "jpg" || "${ext,,}" == "jpeg" ]] && echo jpg || echo png )
  out="$OUTPUT_DIR/${name}_${W}x${H}.${out_ext}"
  echo "→ $out"
  ffmpeg -y -hide_banner -loglevel error -i "$f" \
    -vf "scale=${W}:${H}:force_original_aspect_ratio=decrease,pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:color=black" \
    "$out"
done

echo "Done. Output: $OUTPUT_DIR"
