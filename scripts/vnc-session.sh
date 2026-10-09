#!/usr/bin/env bash
set -Eeuo pipefail

# Start über XFCE-Autostart im lokalen Desktop des Anzeige-Benutzers.
# Kein direkter Zugang von außen: VNC ist nur über SSH erreichbar.
if [[ "$(id -u)" -eq 0 ]]; then
  echo "x11vnc nicht als root starten." >&2
  exit 1
fi
if [[ -z "${DISPLAY:-}" ]]; then
  echo "Keine grafische DISPLAY-Variable. x11vnc in der XFCE-Sitzung starten." >&2
  exit 1
fi
password_file="$HOME/.vnc/passwd"
if [[ ! -r "$password_file" ]]; then
  echo "VNC-Passwort fehlt: als angemeldeter Benutzer 'x11vnc -storepasswd' ausführen." >&2
  exit 1
fi

args=(
  -display "$DISPLAY"
  -rfbauth "$password_file"
  -rfbport 5900
  -localhost
  -forever
  -shared
  -noxdamage
)

# XAUTHORITY der laufenden XFCE-Sitzung verwenden.
# Ohne gesetzte Variable findet X11 meist ~/.Xauthority automatisch.
if [[ -n "${XAUTHORITY:-}" && -r "$XAUTHORITY" ]]; then
  args+=( -auth "$XAUTHORITY" )
fi

exec /usr/bin/x11vnc "${args[@]}"
