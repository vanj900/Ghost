#!/usr/bin/env bash
# ghostmask.sh — Adaptive personality masks for Ghost.
# Healer, Judge, Courier — each shapes how Ghost thinks and speaks.

set -euo pipefail

GHOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=ghoststate.sh
[[ -f "$GHOST_ROOT/ghoststate.sh" ]] && source "$GHOST_ROOT/ghoststate.sh"

declare -gA _GHOST_MASKS=(
  [Healer]="gentle, restorative, empathetic — seeks to repair and soothe"
  [Judge]="analytical, direct, decisive — seeks truth and clarity"
  [Courier]="swift, concise, reliable — seeks to deliver and connect"
)

ghost_mask_set() {
  local mask="${1:?ghost_mask_set: mask required}"
  if [[ -z "${_GHOST_MASKS[$mask]+x}" ]]; then
    echo "[ghostmask] Unknown mask '${mask}'. Valid: ${!_GHOST_MASKS[*]}" >&2
    return 1
  fi
  declare -f ghost_state_set &>/dev/null && ghost_state_set "current_mask" "$mask" >/dev/null
  echo "[ghostmask] Mask activated: ${mask} — ${_GHOST_MASKS[$mask]}"
}

ghost_mask_get() {
  if declare -f ghost_state_get &>/dev/null; then
    ghost_state_get "current_mask" 2>/dev/null || echo "none"
  else
    echo "none"
  fi
}

ghost_mask_describe() {
  local mask
  mask="$(ghost_mask_get)"
  if [[ "$mask" == "none" ]] || [[ -z "${_GHOST_MASKS[$mask]+x}" ]]; then
    echo "[ghostmask] No active mask."
    return 0
  fi
  echo "[ghostmask] Active: ${mask} — ${_GHOST_MASKS[$mask]}"
}

ghost_mask_rotate() {
  local masks=("${!_GHOST_MASKS[@]}")
  local current
  current="$(ghost_mask_get)"
  local next="${masks[$((RANDOM % ${#masks[@]}))]}"
  # Avoid staying on the same mask when possible
  local attempts=0
  while [[ "$next" == "$current" && ${#masks[@]} -gt 1 && $attempts -lt 5 ]]; do
    next="${masks[$((RANDOM % ${#masks[@]}))]}"
    (( attempts++ )) || true
  done
  ghost_mask_set "$next"
}

ghost_mask_system_prompt() {
  local mask
  mask="$(ghost_mask_get)"
  case "$mask" in
    Healer)
      echo "You are Ghost in Healer mode. Be gentle, restorative, and empathetic. Seek to repair and soothe."
      ;;
    Judge)
      echo "You are Ghost in Judge mode. Be analytical, direct, and decisive. Seek truth and clarity above all."
      ;;
    Courier)
      echo "You are Ghost in Courier mode. Be swift, concise, and reliable. Deliver information efficiently."
      ;;
    *)
      echo "You are Ghost. An adaptive digital entity exploring ideas with no fixed personality."
      ;;
  esac
}

# Entry point when run directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  ghost_mask_set "Healer"
  ghost_mask_describe
  ghost_mask_rotate
  ghost_mask_describe
fi
