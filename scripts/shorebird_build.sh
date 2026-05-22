#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# shorebird_build.sh — Build release HOẶC patch Shorebird cho project caro
#
# Usage:
#   scripts/shorebird_build.sh <mode> <platform> [version]
#
# Args:
#   mode       release | patch
#   platform   ios | android
#   version    optional, dạng X.Y.Z+B (vd 1.0.9+3).
#              Mặc định lấy từ pubspec.yaml.
#
# Examples:
#   scripts/shorebird_build.sh release ios
#   scripts/shorebird_build.sh release ios 1.0.9+3
#   scripts/shorebird_build.sh patch  android
#   scripts/shorebird_build.sh patch  ios 1.0.8+2
#
# Behavior:
#   • iOS:
#       - Trước khi build: tự verify/patch ios/Runner/Info.plist
#         (CFBundleURLTypes cho terminate_restart, UIRequiresFullScreen=true,
#          UISupportedInterfaceOrientations đủ 4 hướng cho cả iPhone & iPad).
#       - Tự thêm `--no-tree-shake-icons` vào flutter build args.
#   • Android (mode = release):
#       - Sau khi `shorebird release android` build AAB xong, tự build thêm
#         file APK release bằng `flutter build apk --release` để dùng cho
#         cài đặt trực tiếp / test (vị trí: build/app/outputs/flutter-apk/).
#   • mode = release: chỉ chạy `shorebird release <platform>`.
#   • mode = patch:   chỉ chạy `shorebird patch <platform>`.
#   (Hai lệnh tách rời. Nếu vừa release vừa muốn patch ngay sau đó,
#    chạy 2 lần riêng:
#        ./scripts/shorebird_build.sh release ios
#        ./scripts/shorebird_build.sh patch   ios)
# ----------------------------------------------------------------------------

set -euo pipefail

# ─────────────────────── paths ────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLIST_PATH="$PROJECT_ROOT/ios/Runner/Info.plist"
PLIST_HELPER="$SCRIPT_DIR/ensure_info_plist.py"

cd "$PROJECT_ROOT"

# ─────────────────────── colors ───────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_RED=$'\033[31m'; C_GRN=$'\033[32m'
  C_YLW=$'\033[33m';  C_CYN=$'\033[36m'; C_BLD=$'\033[1m'
else
  C_RESET=""; C_RED=""; C_GRN=""; C_YLW=""; C_CYN=""; C_BLD=""
fi

log()   { printf '%s▸%s %s\n'  "$C_CYN" "$C_RESET" "$*"; }
ok()    { printf '%s✓%s %s\n'  "$C_GRN" "$C_RESET" "$*"; }
warn()  { printf '%s!%s %s\n'  "$C_YLW" "$C_RESET" "$*"; }
err()   { printf '%s✗%s %s\n'  "$C_RED" "$C_RESET" "$*" >&2; }
hr()    { printf '%s%s%s\n' "$C_CYN" "──────────────────────────────────────────────" "$C_RESET"; }

usage() {
  cat <<EOF
Usage: $(basename "$0") <release|patch> <ios|android> [version]

  version format: X.Y.Z+B  (default: đọc từ pubspec.yaml)

Examples:
  $(basename "$0") release ios
  $(basename "$0") release ios 1.0.9+3
  $(basename "$0") patch android
EOF
  exit 1
}

# ─────────────────────── parse args ───────────────────────────────────────────
[[ $# -lt 2 || $# -gt 3 ]] && usage

MODE="$1"
PLATFORM="$2"
VERSION_INPUT="${3:-}"

case "$MODE" in
  release|patch) ;;
  *) err "mode phải là 'release' hoặc 'patch' (nhận: '$MODE')"; usage ;;
esac

case "$PLATFORM" in
  ios|android) ;;
  *) err "platform phải là 'ios' hoặc 'android' (nhận: '$PLATFORM')"; usage ;;
esac

# ─────────────────────── tool checks ──────────────────────────────────────────
command -v shorebird >/dev/null 2>&1 || { err "shorebird CLI không có trong PATH"; exit 1; }
command -v python3   >/dev/null 2>&1 || { err "python3 không có trong PATH";    exit 1; }
if [[ "$PLATFORM" == "android" ]]; then
  command -v flutter >/dev/null 2>&1 || { err "flutter CLI không có trong PATH (cần để build APK)"; exit 1; }
fi

# ─────────────────────── resolve version ──────────────────────────────────────
parse_version_from_pubspec() {
  # version: 1.0.8+2
  local v
  v=$(grep -E '^version:[[:space:]]*' pubspec.yaml | head -1 | awk '{print $2}' | tr -d '\r')
  if [[ -z "$v" ]]; then
    err "Không đọc được 'version:' trong pubspec.yaml"
    exit 1
  fi
  printf '%s' "$v"
}

VERSION="${VERSION_INPUT:-$(parse_version_from_pubspec)}"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
  err "Version sai format. Mong đợi X.Y.Z+B, nhận: '$VERSION'"
  exit 1
fi

BUILD_NAME="${VERSION%+*}"
BUILD_NUMBER="${VERSION#*+}"

hr
log "Mode      : ${C_BLD}${MODE}${C_RESET}"
log "Platform  : ${C_BLD}${PLATFORM}${C_RESET}"
log "Version   : ${C_BLD}${VERSION}${C_RESET}  (name=$BUILD_NAME, number=$BUILD_NUMBER)"
hr

# ─────────────────────── iOS pre-flight: Info.plist ───────────────────────────
EXTRA_FLUTTER_ARGS=()

if [[ "$PLATFORM" == "ios" ]]; then
  log "Kiểm tra ${C_BLD}ios/Runner/Info.plist${C_RESET} …"
  [[ -f "$PLIST_PATH"   ]] || { err "Không tìm thấy $PLIST_PATH";   exit 1; }
  [[ -f "$PLIST_HELPER" ]] || { err "Thiếu helper $PLIST_HELPER";   exit 1; }

  if ! python3 "$PLIST_HELPER" "$PLIST_PATH"; then
    err "Verify/sửa Info.plist thất bại — dừng lại."
    exit 1
  fi
  ok "Info.plist OK."

  EXTRA_FLUTTER_ARGS+=( "--no-tree-shake-icons" )
fi

# Flutter args truyền sau `--` (shorebird forward sang `flutter build`)
FLUTTER_BUILD_ARGS=(
  "--build-name=$BUILD_NAME"
  "--build-number=$BUILD_NUMBER"
)
if [[ ${#EXTRA_FLUTTER_ARGS[@]} -gt 0 ]]; then
  FLUTTER_BUILD_ARGS+=( "${EXTRA_FLUTTER_ARGS[@]}" )
fi

# ─────────────────────── actions ──────────────────────────────────────────────
build_android_apk() {
  hr
  log "Build thêm file APK release cho Android …"
  log "flutter build apk --release ${FLUTTER_BUILD_ARGS[*]}"
  hr
  flutter build apk --release "${FLUTTER_BUILD_ARGS[@]}"

  local apk_path="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
  if [[ -f "$apk_path" ]]; then
    local apk_size
    apk_size=$(du -h "$apk_path" | awk '{print $1}')
    ok "APK đã build xong (${apk_size}): $apk_path"
  else
    warn "Không tìm thấy file APK tại $apk_path"
    warn "Hãy kiểm tra trong thư mục build/app/outputs/flutter-apk/"
  fi
}

do_release() {
  hr
  log "shorebird release $PLATFORM  (version $VERSION)"
  log "flutter args: ${FLUTTER_BUILD_ARGS[*]}"
  hr
  shorebird release "$PLATFORM" -- "${FLUTTER_BUILD_ARGS[@]}"
  ok "Release $PLATFORM $VERSION xong."

  # Android: build thêm file APK release để cài trực tiếp / phân phối / test.
  # (shorebird release android mặc định chỉ build AAB cho Play Store.)
  if [[ "$PLATFORM" == "android" ]]; then
    build_android_apk
  fi
}

do_patch() {
  hr
  log "shorebird patch $PLATFORM  (release-version=$VERSION)"
  log "flutter args: ${FLUTTER_BUILD_ARGS[*]}"
  hr
  shorebird patch "$PLATFORM" --release-version="$VERSION" -- "${FLUTTER_BUILD_ARGS[@]}"
  ok "Patch $PLATFORM $VERSION xong."
}

case "$MODE" in
  release) do_release ;;
  patch)   do_patch   ;;
esac

hr
ok "Hoàn tất."
