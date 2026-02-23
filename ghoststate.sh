#!/usr/bin/env bash
# ghoststate.sh — In-memory state management for Ghost.
# All state lives in associative arrays. Nothing touches the filesystem.

set -euo pipefail

# Internal state store (associative array)
declare -gA _GHOST_STATE=()

ghost_state_set() {
  local key="${1:?ghost_state_set: key required}"
  local value="${2:-}"
  _GHOST_STATE["$key"]="$value"
  echo "[ghoststate] SET ${key}=${value}"
}

ghost_state_get() {
  local key="${1:?ghost_state_get: key required}"
  if [[ -v _GHOST_STATE["$key"] ]]; then
    echo "${_GHOST_STATE[$key]}"
  else
    echo "[ghoststate] WARN: key '${key}' not found." >&2
    return 1
  fi
}

ghost_state_delete() {
  local key="${1:?ghost_state_delete: key required}"
  unset "_GHOST_STATE[$key]"
  echo "[ghoststate] DEL ${key}"
}

ghost_state_dump() {
  echo "[ghoststate] Current state:"
  for key in "${!_GHOST_STATE[@]}"; do
    echo "  ${key} = ${_GHOST_STATE[$key]}"
  done
}

ghost_state_clear() {
  _GHOST_STATE=()
  echo "[ghoststate] State cleared."
}

# Entry point when run directly — run a quick self-test
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  ghost_state_set "status" "alive"
  ghost_state_set "last_action" "init"
  ghost_state_dump
  ghost_state_delete "last_action"
  ghost_state_dump
  ghost_state_clear
  ghost_state_dump
fi
