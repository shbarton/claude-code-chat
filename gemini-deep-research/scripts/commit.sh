#!/usr/bin/env bash
set -euo pipefail
FILEPATH="${1:?Usage: commit.sh path/to/file.pdf}"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
cd "$REPO_ROOT"
git add "$FILEPATH"
git commit -m "Add Gemini Deep Research: $(basename "$FILEPATH")" >/dev/null
git rev-parse --short HEAD
