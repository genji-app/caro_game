#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Shorebird helper for co_caro_flame
# ----------------------------------------------------------------------------
# Wraps `shorebird release` / `shorebird patch` for Android + iOS so you don't
# have to remember the `--` separator and flag list.
#
# Usage:
#   ./tools/shorebird.sh                              # interactive menu
#   ./tools/shorebird.sh release android              # release Android only
#   ./tools/shorebird.sh release ios                  # release iOS only
#   ./tools/shorebird.sh release both                 # release Android + iOS
#   ./tools/shorebird.sh patch android 1.0.8+2        # patch Android for v1.0.8+2
#   ./tools/shorebird.sh patch ios 1.0.8+2            # patch iOS for v1.0.8+2
#   ./tools/shorebird.sh patch both 1.0.8+2           # patch both
#
# Optional env vars:
#   TRACK=staging   ./tools/shorebird.sh patch ios 1.0.8+2     # push to staging
#   EXTRA_ARGS="--obfuscate --split-debug-info=build/symbols"  # extra flutter args
#   STAGED_ROLLOUT=20   # only for `patch` — rollout percentage 1..100
# ----------------------------------------------------------------------------

set -euo pipefail

# ---------- colors -----------------------------------------------------------
if [ -t 1 ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GREEN=$'\033[32m'
  YELLOW=$'\033[33m'; BLUE=$'\033[34m'; CYAN=$'\033[36m'; RESET=$'\033[0m'
else
  BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""; RESET=""
fi

log()     { printf "%s\n" "$*"; }
info()    { printf "%s[INFO]%s %s\n" "$BLUE" "$RESET" "$*"; }
ok()      { printf "%s[ OK ]%s %s\n" "$GREEN" "$RESET" "$*"; }
warn()    { printf "%s[WARN]%s %s\n" "$YELLOW" "$RESET" "$*"; }
err()     { printf "%s[FAIL]%s %s\n" "$RED" "$RESET" "$*" >&2; }
section() { printf "\n%s━━━ %s ━━━%s\n" "$CYAN$BOLD" "$*" "$RESET"; }

# ---------- locate project root ---------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

if [ ! -f "pubspec.yaml" ]; then
  err "pubspec.yaml not found at $PROJECT_ROOT — run this script from inside the project."
  exit 1
fi

# ---------- preflight --------------------------------------------------------
require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Missing required command: $1"
    exit 1
  fi
}
require_cmd shorebird
require_cmd flutter

# Pull the current version from pubspec.yaml (e.g. "1.0.8+2")
PUBSPEC_VERSION=$(grep -E '^version:' pubspec.yaml | awk '{print $2}' | tr -d '\r')
if [ -z "${PUBSPEC_VERSION:-}" ]; then
  warn "Could not read version from pubspec.yaml — using empty value."
  PUBSPEC_VERSION=""
fi

# Default flutter pass-through args. --no-tree-shake-icons MUST stay here so the
# asset hash matches between release and patches.
DEFAULT_FLUTTER_ARGS=( --no-tree-shake-icons )

# Allow the caller to add more flags via EXTRA_ARGS env var
EXTRA_FLUTTER_ARGS=()
if [ "${EXTRA_ARGS:-}" != "" ]; then
  # word-split EXTRA_ARGS into the array
  # shellcheck disable=SC2206
  EXTRA_FLUTTER_ARGS=( $EXTRA_ARGS )
fi

TRACK="${TRACK:-}"               # staging / beta / stable / <custom>
STAGED_ROLLOUT="${STAGED_ROLLOUT:-}"

confirm() {
  # confirm "Proceed?" → returns 0 if yes
  local prompt="$1"
  local answer
  printf "%s%s [y/N]:%s " "$YELLOW" "$prompt" "$RESET"
  read -r answer || true
  case "${answer:-}" in
    y|Y|yes|YES) return 0 ;;
    *)           return 1 ;;
  esac
}

# ---------- actions ----------------------------------------------------------
build_release_args() {
  # echo the "--" + flutter args portion as a single line
  printf -- "-- "
  printf "%s " "${DEFAULT_FLUTTER_ARGS[@]}"
  if [ "${#EXTRA_FLUTTER_ARGS[@]}" -gt 0 ]; then
    printf "%s " "${EXTRA_FLUTTER_ARGS[@]}"
  fi
}

run_release() {
  local platform="$1"
  section "RELEASE $platform (pubspec version: $PUBSPEC_VERSION)"

  local cmd=( shorebird release "$platform" )
  cmd+=( -- "${DEFAULT_FLUTTER_ARGS[@]}" )
  if [ "${#EXTRA_FLUTTER_ARGS[@]}" -gt 0 ]; then
    cmd+=( "${EXTRA_FLUTTER_ARGS[@]}" )
  fi

  info "Running: ${cmd[*]}"
  "${cmd[@]}"
  ok "Release $platform done."
}

run_patch() {
  local platform="$1"
  local version="$2"

  if [ -z "$version" ]; then
    err "Missing release-version. Patches MUST target an existing release."
    exit 1
  fi

  section "PATCH $platform → release-version=$version"

  local cmd=( shorebird patch "$platform" --release-version="$version" )

  if [ -n "$TRACK" ]; then
    cmd+=( --track="$TRACK" )
    info "Track: $TRACK"
  fi
  if [ -n "$STAGED_ROLLOUT" ]; then
    cmd+=( --staged-rollout-percentage="$STAGED_ROLLOUT" )
    info "Staged rollout: $STAGED_ROLLOUT%"
  fi

  cmd+=( -- "${DEFAULT_FLUTTER_ARGS[@]}" )
  if [ "${#EXTRA_FLUTTER_ARGS[@]}" -gt 0 ]; then
    cmd+=( "${EXTRA_FLUTTER_ARGS[@]}" )
  fi

  info "Running: ${cmd[*]}"
  "${cmd[@]}"
  ok "Patch $platform done."
}

# ---------- interactive menu -------------------------------------------------
interactive_menu() {
  section "Shorebird helper — interactive mode"
  log "pubspec version: ${BOLD}${PUBSPEC_VERSION}${RESET}"
  log ""
  log "  1) Release Android"
  log "  2) Release iOS"
  log "  3) Release BOTH (Android + iOS)"
  log "  4) Patch   Android"
  log "  5) Patch   iOS"
  log "  6) Patch   BOTH (Android + iOS)"
  log "  q) Quit"
  log ""
  printf "Choose: "
  read -r choice

  local platforms=()
  local action=""

  case "$choice" in
    1) action="release"; platforms=(android) ;;
    2) action="release"; platforms=(ios) ;;
    3) action="release"; platforms=(android ios) ;;
    4) action="patch";   platforms=(android) ;;
    5) action="patch";   platforms=(ios) ;;
    6) action="patch";   platforms=(android ios) ;;
    q|Q) log "Bye."; exit 0 ;;
    *)   err "Invalid choice."; exit 1 ;;
  esac

  local version=""
  if [ "$action" = "patch" ]; then
    printf "Release version to patch (default %s): " "${PUBSPEC_VERSION}"
    read -r version
    version="${version:-$PUBSPEC_VERSION}"
    if [ -z "$TRACK" ]; then
      printf "Track (stable/staging/beta) [press enter = stable]: "
      read -r TRACK
    fi
  fi

  confirm "Proceed with $action ${platforms[*]}?" || { warn "Aborted."; exit 0; }

  for p in "${platforms[@]}"; do
    if [ "$action" = "release" ]; then
      run_release "$p"
    else
      run_patch "$p" "$version"
    fi
  done
}

# ---------- CLI mode ---------------------------------------------------------
main() {
  if [ $# -eq 0 ]; then
    interactive_menu
    exit 0
  fi

  local action="${1:-}"
  local platform="${2:-}"
  local version="${3:-$PUBSPEC_VERSION}"

  case "$action" in
    release)
      case "$platform" in
        android|ios) run_release "$platform" ;;
        both)        run_release android; run_release ios ;;
        *) err "Usage: $0 release <android|ios|both>"; exit 1 ;;
      esac
      ;;

    patch)
      case "$platform" in
        android|ios) run_patch "$platform" "$version" ;;
        both)        run_patch android "$version"; run_patch ios "$version" ;;
        *) err "Usage: $0 patch <android|ios|both> [release-version]"; exit 1 ;;
      esac
      ;;

    -h|--help|help)
      sed -n '2,25p' "$0"
      ;;

    *)
      err "Unknown action: $action"
      err "Usage: $0 [release|patch] [android|ios|both] [version]"
      exit 1
      ;;
  esac
}

main "$@"
