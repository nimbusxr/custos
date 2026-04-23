#!/usr/bin/env bash
#
# Install the CUST/OS skill kit onto a connected Android device.
#
#   - Pushes custos.yaml to /sdcard/atak/custos/config/
#   - Pushes every skill in skills/ to /sdcard/atak/custos/skills/<group>.<name>/
#   - Pushes every scratch file in scratches/ to /sdcard/atak/custos/scratch/
#   - Pushes any on-device model weights in models/ to /sdcard/atak/custos/models/
#
# Usage (from a clone):
#
#   ./install.sh
#
# Usage (one-shot, no clone needed):
#
#   curl -fsSL https://custos.nimbusxr.us/install.sh | bash
#
# When run outside a clone (e.g. via curl-pipe), the script bootstraps
# itself: clones this repo into a temp dir and re-execs from there. It
# also offers to install `adb` and `git` if they're missing.
#
# The CUST/OS plugin APK must already be installed on the device.

set -euo pipefail

REPO_URL="https://github.com/nimbusxr/custos.git"

BOLD=$(tput bold 2>/dev/null || true)
RESET=$(tput sgr0 2>/dev/null || true)

say()  { echo "${BOLD}>>${RESET} $*"; }
warn() { echo "${BOLD}!!${RESET} $*" >&2; }
die()  { warn "$*"; exit 1; }

# Works whether stdin is a tty (interactive) or a pipe (curl-pipe-bash).
# Reading from /dev/tty is the canonical way to prompt inside a piped
# install script.
prompt() {
  local reply
  if [ -r /dev/tty ]; then
    read -r -p "$1" reply < /dev/tty
  else
    read -r -p "$1" reply
  fi
  printf '%s' "$reply"
}

confirm() {
  local answer
  answer=$(prompt "$1 [Y/n] ")
  [[ "${answer:-Y}" =~ ^[Nn]$ ]] && return 1
  return 0
}

# ----------------------------------------------------------------------
# OS detection + dependency install
# ----------------------------------------------------------------------

OS=""
case "$(uname -s)" in
  Darwin) OS="mac" ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then OS="wsl"; else OS="linux"; fi
    ;;
  *) die "Unsupported OS. Supports macOS, Linux, and WSL. For Windows, use WSL." ;;
esac

ensure_tool() {
  local tool="$1"
  local mac_pkg="$2"      # brew formula, or "cask:<name>" for a cask
  local apt_pkg="$3"      # apt-get package
  local pacman_pkg="$4"   # pacman package

  command -v "$tool" >/dev/null 2>&1 && return 0

  say "$tool not found."
  case "$OS" in
    mac)
      if ! command -v brew >/dev/null 2>&1; then
        die "Homebrew not found. Install from https://brew.sh then re-run."
      fi
      confirm "Install $tool via Homebrew?" \
        || die "Aborted — install $tool manually, then re-run."
      if [[ "$mac_pkg" == cask:* ]]; then
        brew install --cask "${mac_pkg#cask:}"
      else
        brew install "$mac_pkg"
      fi
      ;;
    linux|wsl)
      if command -v apt-get >/dev/null 2>&1; then
        confirm "Install $tool via apt? (requires sudo)" \
          || die "Aborted — install $tool manually, then re-run."
        sudo apt-get update
        sudo apt-get install -y "$apt_pkg"
      elif command -v pacman >/dev/null 2>&1; then
        confirm "Install $tool via pacman? (requires sudo)" \
          || die "Aborted — install $tool manually, then re-run."
        sudo pacman -S --noconfirm "$pacman_pkg"
      else
        die "No supported package manager (apt, pacman). Install $tool manually."
      fi
      ;;
  esac
}

# ----------------------------------------------------------------------
# Self-bootstrap: if we're running outside a clone, clone and re-exec
# ----------------------------------------------------------------------

SCRIPT_SOURCE="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" 2>/dev/null && pwd || echo "")"

if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/custos.yaml" ]; then
  ensure_tool git git git git

  CLONE_DIR="${TMPDIR:-/tmp}/custos-install-$$"
  trap '[ -d "$CLONE_DIR" ] && rm -rf "$CLONE_DIR"' EXIT
  say "Cloning starter kit from $REPO_URL..."
  git clone --depth 1 "$REPO_URL" "$CLONE_DIR" >/dev/null 2>&1 \
    || die "Clone failed. Check your internet connection and that $REPO_URL is reachable."
  cd "$CLONE_DIR"
  exec bash ./install.sh "$@"
fi

ROOT_DIR="$SCRIPT_DIR"

# ----------------------------------------------------------------------
# Running inside a clone: ensure adb + connected device, then push
# ----------------------------------------------------------------------

ensure_tool adb cask:android-platform-tools android-tools-adb android-tools

echo "=== CUST/OS Skill Kit Install ==="

adb start-server >/dev/null 2>&1 || true
if [ "$(adb get-state 2>/dev/null || true)" != "device" ]; then
  cat <<EOF >&2

ERROR: no authorized device detected.

Checklist:
  1. The CUST/OS plugin APK is installed on your phone.
  2. USB debugging is enabled in Developer Options.
  3. The phone is plugged in with a data-capable USB cable.
  4. You've tapped "Allow" on the "Allow USB debugging?" prompt.

Run 'adb devices' to verify, then re-run this installer.
EOF
  exit 1
fi

# 1. Config
echo "[1/4] Pushing custos.yaml..."
adb shell mkdir -p /sdcard/atak/custos/config
adb push "$ROOT_DIR/custos.yaml" /sdcard/atak/custos/config/custos.yaml >/dev/null

# 2. Skills
echo "[2/4] Pushing skills..."
adb shell mkdir -p /sdcard/atak/custos/skills
skill_count=0
for skill_dir in "$ROOT_DIR"/skills/custos.*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    adb shell mkdir -p "/sdcard/atak/custos/skills/$skill_name"
    adb push "$skill_dir". "/sdcard/atak/custos/skills/$skill_name/" >/dev/null
    skill_count=$((skill_count + 1))
done
echo "      Pushed $skill_count skills."

# 3. Scratches (optional)
SCRATCHES_DIR="$ROOT_DIR/scratches"
if [ -d "$SCRATCHES_DIR" ]; then
    echo "[3/4] Pushing scratches..."
    adb shell mkdir -p /sdcard/atak/custos/scratch
    adb push "$SCRATCHES_DIR"/*.lua /sdcard/atak/custos/scratch/ >/dev/null 2>&1 || true
    scratch_count=$(ls "$SCRATCHES_DIR"/*.lua 2>/dev/null | wc -l | tr -d ' ')
    echo "      Pushed $scratch_count scratch files."
else
    echo "[3/4] No scratches/ directory — skipping."
fi

# 4. Model weights (optional — only if models/ has files)
MODELS_DIR="$ROOT_DIR/models"
if [ -d "$MODELS_DIR" ]; then
    model_files=$(find "$MODELS_DIR" -maxdepth 1 -type f \
        \( -name "*.litertlm" -o -name "*.gguf" -o -name "*.bin" \
           -o -name "*.onnx" -o -name "*.jinja" \) 2>/dev/null)
    if [ -n "$model_files" ]; then
        echo "[4/4] Pushing model weights..."
        adb shell mkdir -p /sdcard/atak/custos/models
        model_count=0
        while IFS= read -r model_file; do
            [ -z "$model_file" ] && continue
            echo "      Pushing $(basename "$model_file") ($(du -h "$model_file" | cut -f1))..."
            adb push "$model_file" /sdcard/atak/custos/models/ >/dev/null
            model_count=$((model_count + 1))
        done <<< "$model_files"
        echo "      Pushed $model_count model files."
    else
        echo "[4/4] models/ exists but is empty — skipping. See models/README.md for what to download."
    fi
else
    echo "[4/4] No models/ directory — skipping."
fi

echo ""
echo "Done. The plugin will hot-reload skills automatically."
echo ""
echo "Verify in the Status panel, or via:"
echo "  adb logcat | grep 'Loaded skill'"
echo ""
echo "If any on-device provider shows offline, you likely need model weights."
echo "See: https://github.com/nimbusxr/custos/blob/main/models/README.md"
