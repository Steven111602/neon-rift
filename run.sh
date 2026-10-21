#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
python3 tools/build.py
if [[ "${1:-web}" == "desktop" ]]; then
  command -v love >/dev/null || { echo 'Installer LÖVE : https://love2d.org'; exit 1; }
  love .
else
  echo 'Ouvrir http://localhost:8000/web/'
  python3 -m http.server 8000 --bind 127.0.0.1
fi
