#!/usr/bin/env bash
# gstack environment detection — outputs JSON with system capabilities
set -e

detect_os() {
  local os="unknown"
  case "$(uname -s)" in
    Darwin)  os="macos" ;;
    Linux)
      if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
        os="wsl"
      else
        os="linux"
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*) os="windows" ;;
  esac
  echo "$os"
}

detect_display() {
  local os="$1"
  if [ "$os" = "macos" ]; then
    echo "true"
  elif [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    echo "true"
  else
    echo "false"
  fi
}

detect_cookie_import() {
  local os="$1"
  if [ "$os" = "macos" ] && command -v security >/dev/null 2>&1; then
    echo "true"
  else
    echo "false"
  fi
}

OS=$(detect_os)
HAS_DISPLAY=$(detect_display "$OS")
HAS_COOKIE_IMPORT=$(detect_cookie_import "$OS")
HAS_BUN=$(command -v bun >/dev/null 2>&1 && echo "true" || echo "false")
HAS_GIT=$(command -v git >/dev/null 2>&1 && echo "true" || echo "false")
BUN_VERSION=$(bun --version 2>/dev/null || echo "none")

cat <<EOF
{
  "os": "$OS",
  "has_display": $HAS_DISPLAY,
  "has_cookie_import_browser": $HAS_COOKIE_IMPORT,
  "has_bun": $HAS_BUN,
  "has_git": $HAS_GIT,
  "bun_version": "$BUN_VERSION"
}
EOF
