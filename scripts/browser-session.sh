#!/usr/bin/env bash
set -uo pipefail

# Läuft im grafischen XFCE-Desktop des konfigurierten Anzeige-Benutzers (standardmäßig cevik).
cfg=/etc/ticket-display.conf
if [[ ! -r "$cfg" ]]; then
  echo "Konfiguration fehlt: $cfg" >&2; exit 1
fi
# Die Datei muss lokal root-kontrolliert sein; keine Zugangsdaten hineinlegen.
# shellcheck disable=SC1090
. "$cfg"
url="${TICKET_URL:-}"
display_user="${DISPLAY_USER:-cevik}"
if [[ "$(id -un)" != "$display_user" ]]; then
  echo "Browser muss als $display_user gestartet werden, nicht als $(id -un)." >&2
  exit 1
fi
case "$url" in
  http://*|https://*) ;;
  *) echo "TICKET_URL ist keine http(s)-Adresse; /etc/ticket-display.conf prüfen" >&2; exit 1 ;;
esac

state="$HOME/.local/state/ticket-display"
mkdir -p "$state" "$HOME/.cache/ticket-display"
pid_file="$state/browser.pid"

# Entpackte Extension aus vertrauenswürdigen, lokal installierten Dateien
# erstellen. config.js enthält NUR die lokale Ziel-URL (keine Secrets).
extension_source="/usr/local/share/ticket-display/extension"
extension_dir="$HOME/.local/share/ticket-display/extension"
if [[ ! -f "$extension_source/manifest.json" || ! -f "$extension_source/background.js" ]]; then
  echo "Ticket-Refresh-Extension fehlt. Installer erneut ausführen." >&2
  exit 1
fi
mkdir -p "$extension_dir"
cp "$extension_source/manifest.json" "$extension_dir/manifest.json"
cp "$extension_source/background.js" "$extension_dir/background.js"
chmod 0644 "$extension_dir/manifest.json" "$extension_dir/background.js"

python3 - "$url" "$extension_dir/config.js" <<'PY'
import json
import pathlib
import sys
target_url, config_path = sys.argv[1:]
config = {"targetUrl": target_url}
pathlib.Path(config_path).write_text(
    "globalThis.ticketDisplayConfig = " + json.dumps(config) + ";\n",
    encoding="utf-8",
)
PY
chmod 0600 "$extension_dir/config.js"
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
    --load-extension="$extension_dir" \
    --new-window "$url" &
  browser_pid=$!
  printf '%s\n' "$browser_pid" > "$pid_file"
  wait "$browser_pid" || true
  rm -f "$pid_file"
  sleep 3
done
