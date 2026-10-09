#!/usr/bin/env bash
set -Eeuo pipefail

# Nur in der grafischen XFCE-Sitzung des unprivilegierten Anzeige-Benutzers.
# Standard: SSH-Tunnel (127.0.0.1). Direkter Zugriff ist optional und
# ausschließlich über die lokale /etc/ticket-display.conf aktivierbar.
if [[ "$(id -u)" -eq 0 ]]; then
  echo "x11vnc nicht als root starten." >&2
  exit 1
fi
if [[ -z "${DISPLAY:-}" ]]; then
  echo "Keine grafische DISPLAY-Variable: XFCE-Autostart erforderlich." >&2
  exit 1
fi
password_file="$HOME/.vnc/passwd"
if [[ ! -r "$password_file" ]]; then
  echo "VNC-Passwortdatei fehlt: als Display-Benutzer 'x11vnc -storepasswd' ausführen." >&2
  exit 1
fi

if [[ ! -r /etc/ticket-display.conf ]]; then
  echo "/etc/ticket-display.conf fehlt oder ist nicht lesbar." >&2
  exit 1
fi
# shellcheck disable=SC1091
. /etc/ticket-display.conf
vnc_listen_ip="${VNC_LISTEN_IP:-127.0.0.1}"

# IPv4-Ziel strikt auf eine lokale Hostadresse begrenzen (nicht 0.0.0.0).
if [[ ! "$vnc_listen_ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] ||
   [[ "$vnc_listen_ip" == "0.0.0.0" ]]; then
  echo "Ungültige VNC_LISTEN_IP: nur eine konkrete lokale IPv4-Adresse zulässig." >&2
  exit 1
fi
IFS=. read -r a b c d <<< "$vnc_listen_ip"
for octet in "$a" "$b" "$c" "$d"; do
  if (( 10#$octet > 255 )); then
    echo "Ungültige VNC_LISTEN_IP (IPv4-Oktett außerhalb 0..255)." >&2
    exit 1
  fi
done

# WLAN kann beim XFCE-Start noch nicht verbunden sein. Bis zu 180 Sekunden
# warten, bis die konfigurierte Adresse lokal existiert.
if [[ "$vnc_listen_ip" != "127.0.0.1" ]]; then
  ready=false
  for _ in {1..90}; do
    if /usr/sbin/ip -4 -o addr show | grep -Fq "inet $vnc_listen_ip/"; then
      ready=true
      break
    fi
    sleep 2
  done
  if [[ "$ready" != true ]]; then
    echo "VNC-Adresse $vnc_listen_ip ist nach 180 Sekunden nicht verfügbar." >&2
    exit 1
  fi
fi

args=(
  -display "$DISPLAY"
  -rfbauth "$password_file"
  -rfbport 5900
  -listen "$vnc_listen_ip"
  -forever
  -shared
  -noxdamage
)

# Vorhandene XAUTHORITY der grafischen XFCE-Sitzung verwenden.
# Falls nicht gesetzt, kann X11 die Datei unter ~/.Xauthority finden.
if [[ -n "${XAUTHORITY:-}" && -r "$XAUTHORITY" ]]; then
  args+=( -auth "$XAUTHORITY" )
elif [[ -r "$HOME/.Xauthority" ]]; then
  args+=( -auth "$HOME/.Xauthority" )
fi

exec /usr/bin/x11vnc "${args[@]}"
