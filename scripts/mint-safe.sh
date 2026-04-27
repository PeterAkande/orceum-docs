#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PARENT_DIR="$(dirname "$ROOT_DIR")"

EXPORT_DIR="$ROOT_DIR/export"
EXPORT_TMP_DIR="$ROOT_DIR/export__tmp"

MOVED_EXPORT_PARENT=""
MOVED_EXPORT_TMP_PARENT=""

hide_dir() {
  local source_dir="$1"
  local name="$2"
  local tmp_parent

  if [[ -d "$source_dir" ]]; then
    tmp_parent="$(mktemp -d "$PARENT_DIR/.orceum-${name}-hidden.XXXXXX")"
    mv "$source_dir" "$tmp_parent/$name"

    if [[ "$name" == "export" ]]; then
      MOVED_EXPORT_PARENT="$tmp_parent"
    elif [[ "$name" == "export__tmp" ]]; then
      MOVED_EXPORT_TMP_PARENT="$tmp_parent"
    fi

    echo "Temporarily moved $name/ out of docs root."
  fi
}

restore_dir() {
  local name="$1"
  local tmp_parent="$2"
  local source_dir="$ROOT_DIR/$name"
  local hidden_dir="$tmp_parent/$name"

  if [[ -n "$tmp_parent" && -d "$hidden_dir" && ! -e "$source_dir" ]]; then
    mv "$hidden_dir" "$source_dir"
    rmdir "$tmp_parent" 2>/dev/null || true
    echo "Restored $name/."
  fi
}

cleanup() {
  local status=$?

  # Restore in reverse order to preserve original layout if both were moved.
  restore_dir "export__tmp" "$MOVED_EXPORT_TMP_PARENT"
  restore_dir "export" "$MOVED_EXPORT_PARENT"

  return "$status"
}

on_interrupt() {
  exit 130
}

trap on_interrupt INT TERM
trap cleanup EXIT

if command -v mint >/dev/null 2>&1; then
  MINT_BIN="mint"
elif command -v mintlify >/dev/null 2>&1; then
  MINT_BIN="mintlify"
else
  echo "Error: neither 'mint' nor 'mintlify' is installed." >&2
  exit 1
fi

if [[ $# -eq 0 || "${1:-}" == -* ]]; then
  # Allow: ./scripts/mint-safe.sh --port 3000
  set -- dev "$@"
fi

cd "$ROOT_DIR"
hide_dir "$EXPORT_TMP_DIR" "export__tmp"
hide_dir "$EXPORT_DIR" "export"

"$MINT_BIN" "$@"
