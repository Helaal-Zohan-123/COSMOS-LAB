#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$DIR/dist"
PORT=4173
URL="http://127.0.0.1:$PORT/"

if [ ! -f "$DIST_DIR/index.html" ]; then
  echo "[ERROR] Could not find $DIST_DIR/index.html. Please extract the complete ZIP archive first."
  exit 1
fi

open_browser() {
  sleep 1
  if command -v open >/dev/null 2>&1; then
    open "$URL"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$URL" >/dev/null 2>&1 || true
  fi
}

echo "COSMOS LAB — Jezero Evidence Explorer"
echo "Serving: $DIST_DIR"
echo "URL:     $URL"
echo "Press Ctrl+C (or close this terminal) to stop the server."

open_browser &

if command -v python3 >/dev/null 2>&1; then
  exec python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$DIST_DIR"
elif command -v npx >/dev/null 2>&1; then
  exec npx --yes serve -l "tcp://127.0.0.1:$PORT" "$DIST_DIR"
else
  echo "[ERROR] Neither python3 nor npx was found. Please install Python 3 or Node.js, or serve dist/ via a static HTTP server."
  exit 1
fi
