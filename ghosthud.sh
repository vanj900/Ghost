#!/usr/bin/env bash
# ghosthud.sh — Live terminal HUD for Ghost.
# Shows mask, mood, energy, focus, diary count, and recent memories with color bars.

set -euo pipefail

GHOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=ghoststate.sh
[[ -f "$GHOST_ROOT/ghoststate.sh" ]]  && source "$GHOST_ROOT/ghoststate.sh"
# shellcheck source=ghostmemory.sh
[[ -f "$GHOST_ROOT/ghostmemory.sh" ]] && source "$GHOST_ROOT/ghostmemory.sh"
# shellcheck source=ghostmask.sh
[[ -f "$GHOST_ROOT/ghostmask.sh" ]]   && source "$GHOST_ROOT/ghostmask.sh"

# ANSI colour codes
_HUD_RESET='\033[0m'
_HUD_BOLD='\033[1m'
_HUD_DIM='\033[2m'
_HUD_CYAN='\033[36m'
_HUD_GREEN='\033[32m'
_HUD_YELLOW='\033[33m'
_HUD_RED='\033[31m'
_HUD_MAGENTA='\033[35m'
_HUD_BLUE='\033[34m'

# Draw a filled progress bar (value 0-100, width in chars)
_ghost_bar() {
  local value="${1:-0}"
  local width="${2:-20}"
  local color="${3:-$_HUD_GREEN}"
  local filled=$(( value * width / 100 ))
  local empty=$(( width - filled ))
  local i
  printf "%b" "$color"
  for (( i=0; i<filled; i++ )); do printf "█"; done
  printf "%b" "$_HUD_DIM"
  for (( i=0; i<empty; i++ )); do printf "░"; done
  printf "%b" "$_HUD_RESET"
}

ghost_hud_render() {
  clear

  # Gather state values
  local mask="none"
  declare -f ghost_mask_get &>/dev/null && mask="$(ghost_mask_get 2>/dev/null || echo none)"

  local mood="neutral"
  declare -f ghost_state_get &>/dev/null && \
    mood="$(ghost_state_get "mood" 2>/dev/null || echo neutral)"

  local energy=50
  declare -f ghost_state_get &>/dev/null && \
    energy="$(ghost_state_get "energy" 2>/dev/null || echo 50)"

  local focus=50
  declare -f ghost_state_get &>/dev/null && \
    focus="$(ghost_state_get "focus" 2>/dev/null || echo 50)"

  local mem_count=0
  declare -f ghost_memory_count &>/dev/null && \
    mem_count="$(ghost_memory_count 2>/dev/null || echo 0)"

  local cycles=0
  declare -f ghost_state_get &>/dev/null && \
    cycles="$(ghost_state_get "uptime_cycles" 2>/dev/null || echo 0)"

  # Pick a colour for the active mask
  local mask_color="$_HUD_CYAN"
  case "$mask" in
    Healer)  mask_color="$_HUD_GREEN"  ;;
    Judge)   mask_color="$_HUD_RED"    ;;
    Courier) mask_color="$_HUD_YELLOW" ;;
  esac

  # Header
  printf "%b╔══════════════════════════════════════════╗%b\n" \
    "$_HUD_BOLD$_HUD_CYAN" "$_HUD_RESET"
  printf "%b║            ░ G H O S T ░                ║%b\n" \
    "$_HUD_BOLD$_HUD_CYAN" "$_HUD_RESET"
  printf "%b╚══════════════════════════════════════════╝%b\n" \
    "$_HUD_BOLD$_HUD_CYAN" "$_HUD_RESET"
  printf "\n"

  # Identity line
  printf "  %bMask%b   : %b%-12s%b\n" \
    "$_HUD_BOLD" "$_HUD_RESET" "$mask_color" "$mask" "$_HUD_RESET"
  printf "  %bMood%b   : %-12s\n" "$_HUD_BOLD" "$_HUD_RESET" "$mood"
  printf "  %bCycles%b : %-6s  %bDiary entries: %s%b\n" \
    "$_HUD_BOLD" "$_HUD_RESET" "$cycles" "$_HUD_DIM" "$mem_count" "$_HUD_RESET"
  printf "\n"

  # Energy bar
  printf "  %bEnergy%b : " "$_HUD_BOLD" "$_HUD_RESET"
  _ghost_bar "$energy" 20 "$_HUD_GREEN"
  printf "  %3s%%\n" "$energy"

  # Focus bar
  printf "  %bFocus%b  : " "$_HUD_BOLD" "$_HUD_RESET"
  _ghost_bar "$focus" 20 "$_HUD_BLUE"
  printf "  %3s%%\n" "$focus"
  printf "\n"

  # Recent memories
  printf "  %b── Recent Memories ─────────────────────%b\n" \
    "$_HUD_BOLD$_HUD_MAGENTA" "$_HUD_RESET"
  if declare -f ghost_memory_recent &>/dev/null; then
    local i=0
    while IFS= read -r line; do
      printf "  %b%s%b\n" "$_HUD_DIM" "$line" "$_HUD_RESET"
      (( i++ )) || true
    done < <(ghost_memory_recent 5 2>/dev/null)
    [[ $i -eq 0 ]] && printf "  %b(no memories yet)%b\n" "$_HUD_DIM" "$_HUD_RESET"
  else
    printf "  %b(memory module not loaded)%b\n" "$_HUD_DIM" "$_HUD_RESET"
  fi

  printf "\n"
  printf "  %bTalk : echo \"<msg>\" > /tmp/ghost.pipe%b\n" "$_HUD_DIM" "$_HUD_RESET"
  printf "  %bQuit : Ctrl-C%b\n" "$_HUD_DIM" "$_HUD_RESET"
}

ghost_hud_loop() {
  local interval="${1:-5}"
  while true; do
    ghost_hud_render
    sleep "$interval"
  done
}

# Entry point when run directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  ghost_hud_render
fi
