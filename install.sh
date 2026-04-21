#!/usr/bin/env bash
#
# Install the CUST/OS skill kit onto a connected Android device.
#
#   - Pushes custos.yaml to /sdcard/atak/custos/config/
#   - Pushes every skill in skills/ to /sdcard/atak/custos/skills/<group>.<name>/
#   - Pushes every scratch file in scratches/ to /sdcard/atak/custos/scratch/
#   - Pushes any on-device model weights in models/ to /sdcard/atak/custos/models/
#
# Requires: adb, a device connected and authorized.
# The CUST/OS plugin APK must already be installed on the device.
#
# Usage: ./install.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== CUST/OS Skill Kit Install ==="

# Verify a device is connected.
if ! adb get-state >/dev/null 2>&1; then
    echo "ERROR: no device connected. Run 'adb devices' to check." >&2
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
