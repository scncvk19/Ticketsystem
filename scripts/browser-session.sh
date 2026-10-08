#!/usr/bin/env bash
set -uo pipefail

# Läuft nur in der grafischen XFCE-Sitzung des unprivilegierten Users ticketview.
cfg=/etc/ticket-display.conf
if [[ ! -r "$cfg" ]]; then
  echo "Konfiguration fehlt: $cfg" >&2; exit 1
fi
# Die Datei muss lokal root-kontrolliert sein; keine Zugangsdaten hineinlegen.
# shellcheck disable=SC1090
. "$cfg"
url="${TICKET_URL:-}"
case "$url" in
  http://*|https://*) ;;
  *) echo "TICKET_URL ist keine http(s)-Adresse; /etc/ticket-display.conf prüfen" >&2; exit 1 ;;
esac

state="$HOME/.local/state/ticket-display"
mkdir -p "$state" "$HOME/.cache/ticket-display"
pid_file="$state/browser.pid"
# TV-Standby wird über Fernseher/CEC gesteuert; XFCE-X11 soll die
# aktive Anzeige nicht nach wenigen Minuten wegen Inaktivität abdunkeln.
if command -v xset >/dev/null 2>&1; then
  xset s off || true
  xset s noblank || true
  xset -dpms || true
fi
exec 9>"$state/launcher.lock"
/usr/bin/flock -n 9 || exit 0

# Chromium wird bei Schließen/Absturz neu gestartet; ein eigener Profilordner
# verhindert Konflikte mit dem normalen Browser des Geräts.
cleanup() { rm -f "$pid_file"; }
trap cleanup EXIT

while true; do
  /usr/bin/chromium \
    --no-first-run \
    --no-default-browser-check \
    --start-fullscreen \
    --user-data-dir="$HOME/.config/ticket-display-chromium" \
    --new-window "$url" &
  browser_pid=$!
  printf '%s\n' "$browser_pid" > "$pid_file"
  wait "$browser_pid" || true
  rm -f "$pid_file"
  sleep 3
done
