#!/data/data/com.termux/files/usr/bin/bash
# set -euo pipefail

echo "[1/9] Updating Termux packages..."
pkg update -y
pkg upgrade -y

echo "[2/9] Installing base build tools + Python..."
pkg install -y python clang make pkg-config git python-pip

echo "[3/9] Installing lxml system dependencies (libxml2/libxslt)..."
pkg install -y libxml2 libxslt

echo "[4/9] Installing Rust toolchain (for maturin/pyo3 builds)..."
pkg install -y rust

echo "[5/9] Preparing safe temp dir + build settings (avoid 'Text file busy')..."
mkdir -p "$HOME/tmp"
export TMPDIR="$HOME/tmp"
export CARGO_BUILD_JOBS=1

# Android API level (needed by maturin on Termux/Android)
ANDROID_API_LEVEL_DETECTED="$(getprop ro.build.version.sdk 2>/dev/null || true)"
if [ -n "${ANDROID_API_LEVEL_DETECTED}" ]; then
  export ANDROID_API_LEVEL="${ANDROID_API_LEVEL_DETECTED}"
  echo "Detected ANDROID_API_LEVEL=${ANDROID_API_LEVEL}"
else
  # fallback: you can hardcode if detection fails
  export ANDROID_API_LEVEL="33"
  echo "Could not detect API level, defaulting ANDROID_API_LEVEL=33"
fi

echo "[6/9] Upgrading pip tooling..."
python -m pip install -U pip setuptools wheel

echo "[7/9] Installing lxml (build from source if no wheel)..."
python -m pip install -U lxml

echo "[8/9] Installing Rust-based Python deps (tokenizers, fastuuid, hf-xet)..."
# tokenizers often uses maturin/pyo3; needs ANDROID_API_LEVEL and Rust
python -m pip install -U tokenizers

# fastuuid also uses maturin/pyo3
python -m pip install -U fastuuid

# hf-xet is the one that often hits "Text file busy" -> TMPDIR + CARGO_BUILD_JOBS=1 helps
python -m pip install -U hf-xet

echo "[9/9] Installing nanobot..."
python -m pip install -U nanobot-ai

echo
echo "✅ Done. nanobot installed."
echo "Tips:"
echo "  - If a package still fails to compile, paste the LAST 30 lines of the error."
echo "  - Current env: TMPDIR=$TMPDIR, CARGO_BUILD_JOBS=$CARGO_BUILD_JOBS, ANDROID_API_LEVEL=$ANDROID_API_LEVEL"
