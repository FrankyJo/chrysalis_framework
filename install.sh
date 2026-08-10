#!/usr/bin/env bash
# Installs Chrysalis skills into the current project's .claude/skills/.
# Usage (run from your project root):
#   curl -fsSL https://raw.githubusercontent.com/FrankyJo/chrysalis_framework/main/install.sh | bash
#
# Optional: install globally for all projects instead of just this one:
#   curl -fsSL https://raw.githubusercontent.com/FrankyJo/chrysalis_framework/main/install.sh | bash -s -- --global

set -euo pipefail

REPO="FrankyJo/chrysalis_framework"
BRANCH="main"

TARGET_ROOT="$(pwd)/.claude/skills"
for arg in "$@"; do
  if [ "$arg" = "--global" ]; then
    TARGET_ROOT="$HOME/.claude/skills"
  fi
done

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading Chrysalis from github.com/${REPO}@${BRANCH}..."

if command -v git >/dev/null 2>&1; then
  git clone --depth 1 --branch "$BRANCH" "https://github.com/${REPO}.git" "$TMP_DIR/repo" >/dev/null 2>&1
  SRC="$TMP_DIR/repo/skills"
elif command -v curl >/dev/null 2>&1; then
  curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" -o "$TMP_DIR/repo.tar.gz"
  tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR"
  SRC="$(find "$TMP_DIR" -maxdepth 1 -type d -name '*chrysalis*')/skills"
else
  echo "Error: need either git or curl installed." >&2
  exit 1
fi

if [ ! -d "$SRC" ]; then
  echo "Error: couldn't find the skills/ directory after download." >&2
  exit 1
fi

mkdir -p "$TARGET_ROOT"
cp -r "$SRC"/. "$TARGET_ROOT"/

echo ""
echo "Chrysalis skills installed to: $TARGET_ROOT"
echo ""
echo "Restart Claude Code (or start a new session) so it picks them up, then run:"
echo "  /chrysalis-01-project-analyzer"
