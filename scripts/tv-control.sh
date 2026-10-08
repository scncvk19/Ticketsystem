#!/usr/bin/env bash
set -Eeuo pipefail

cfg=/etc/ticket-display.conf
if [[ ! -r "$cfg" ]]; then
  echo "Konfiguration fehlt: $cfg" >&2; exit 1
fi
# config ist nach Installation root-kontrolliert, niemals Credentials hineinlegen
# shellcheck disable=SC1090
. "$cfg"
mode="${TV_CONTROL:-none}"

usage() {
  echo "Aufruf: ticket-display-tv {on|off|sync|status}"
  exit 2
}

if [[ "${1:-}" == "status" ]]; then
  echo "TV_CONTROL=$mode"
  echo "Zeit (Berlin): $(TZ=Europe/Berlin date '+%a %d.%m.%Y %H:%M %Z')"
  if command -v cec-client >/dev/null; then
    timeout 12 cec-client -l || true
  else
    echo "cec-client nicht installiert."
  fi
  exit 0
fi

case "${1:-}" in
  on|off|sync) ;;
  *) usage ;;
esac

# 'none': Zeitsteuerung vollständig im TV selbst einstellen.
if [[ "$mode" == "none" ]]; then
  echo "TV_CONTROL=none: keine HDMI-CEC-Steuerung; TV-internen Wochenplan verwenden."
  exit 0
fi
if [[ "$mode" != "cec" ]]; then
  echo "Ungültiger TV_CONTROL-Wert: $mode. Erlaubt: none oder cec" >&2
  exit 2
fi
if ! command -v cec-client >/dev/null; then
  echo "cec-client fehlt (Paket cec-utils)." >&2; exit 1
fi

send_cec() {
  # 0 = TV (logische CEC-Adresse). Adapter/CEC-Aktivierung sind erforderlich.
  printf '%s\n' "$1" | timeout 25 cec-client -s -d 1
}

on() {
  echo "TV per CEC einschalten..."
  send_cec "on 0"
  sleep 2
  # Adapter meldet sich als aktive HDMI-Quelle, abhängig vom Setup.
  send_cec "as"
}
off() {
  echo "TV per CEC in Standby versetzen..."
  send_cec "standby 0"
}
sync_state() {
  local weekday hhmm
  weekday="$(TZ=Europe/Berlin date +%u)"
  hhmm="$(TZ=Europe/Berlin date +%H%M)"
  if [[ "$weekday" -le 5 && "$hhmm" -ge "0745" && "$hhmm" -lt "1730" ]]; then
    on
  else
    off
  fi
}

case "$1" in
  on) on ;;
  off) off ;;
  sync) sync_state ;;
esac
