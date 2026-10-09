#!/usr/bin/env bash
set -Eeuo pipefail

# Nur für dedizierte Debian-13-/XFCE-Ticketanzeigen gedacht.
if [[ ${EUID} -ne 0 ]]; then
  echo "Bitte mit sudo ausführen: sudo bash scripts/install.sh" >&2
  exit 1
fi
if [[ ! -f /etc/os-release ]]; then
  echo "Kein unterstütztes Linux erkannt." >&2; exit 1
fi
. /etc/os-release
if [[ "${ID:-}" != "debian" ]]; then
  echo "Dieses Installationsskript ist für Debian entwickelt, erkannt: ${PRETTY_NAME:-unbekannt}" >&2
  exit 1
fi

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd -- "$here/.." && pwd)"

# /etc/ticket-display.conf existiert auf bereits installierten Geräten und
# enthält die lokale Ticket-URL. Auf keinen Fall überschreiben.
if [[ ! -e /etc/ticket-display.conf ]]; then
  install -m 0644 "$root/config/ticket-display.conf.example" /etc/ticket-display.conf
fi
# Die Konfiguration ist root-kontrolliert; Benutzername ist optional.
# shellcheck disable=SC1091
. /etc/ticket-display.conf
display_user="${DISPLAY_USER:-cevik}"
if ! id "$display_user" >/dev/null 2>&1; then
  echo "Anzeigebenutzer '$display_user' fehlt. Bitte zuerst regulär in Debian anlegen." >&2
  exit 1
fi
if [[ "$display_user" == "root" ]]; then
  echo "Aus Sicherheitsgründen kein Browser-Autologin als root." >&2
  exit 1
fi
group="$(id -gn "$display_user")"
home="$(getent passwd "$display_user" | cut -d: -f6)"
echo "ACHTUNG: LightDM-Autologin für $display_user und werktägliche TV-Schaltzeiten werden eingerichtet."
echo "Nur auf einem dedizierten Anzeige-PC fortfahren!"
echo
echo "Installiere Debian-Pakete …"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  xfce4 lightdm lightdm-gtk-greeter xorg dbus-x11 \
  chromium chromium-l10n cron cec-utils util-linux x11-xserver-utils python3-minimal x11vnc

# Benutzer ticketview wird nicht mehr angelegt.
# Eine eventuell vorhandene alte Benutzerkennung löschen wir absichtlich
# NICHT automatisch: erst nach Neustart und Prüfung manuell entfernen.

install -m 0755 "$root/scripts/browser-session.sh" /usr/local/bin/ticket-display-browser
install -m 0755 "$root/scripts/refresh-browser.sh" /usr/local/bin/ticket-display-refresh
install -m 0755 "$root/scripts/tv-control.sh" /usr/local/bin/ticket-display-tv
install -m 0755 "$root/scripts/diagnostics.sh" /usr/local/bin/ticket-display-diagnose
install -m 0755 "$root/scripts/vnc-session.sh" /usr/local/bin/ticket-display-vnc

# Erweiterung enthält nur statischen Code. Die echte Ticket-URL bleibt
# lokal in /etc/ticket-display.conf und wird beim Browserstart eingebunden.
install -d -m 0755 /usr/local/share/ticket-display/extension
install -m 0644 "$root/extension/manifest.json" /usr/local/share/ticket-display/extension/manifest.json
install -m 0644 "$root/extension/background.js" /usr/local/share/ticket-display/extension/background.js

install -d -m 0755 -o "$display_user" -g "$group" "$home/.config"
install -d -m 0755 -o "$display_user" -g "$group" "$home/.config/autostart"
install -d -m 0700 -o "$display_user" -g "$group" "$home/.local/state/ticket-display"
install -d -m 0700 -o "$display_user" -g "$group" "$home/.cache/ticket-display"

cat > "$home/.config/autostart/ticket-display.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Ticketanzeige
Comment=Chromium-Ticketanzeige mit Neustart bei Browserende
Exec=/usr/local/bin/ticket-display-browser
Terminal=false
X-GNOME-Autostart-enabled=true
DESKTOP
cat > "$home/.config/autostart/ticket-display-vnc.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Ticketanzeige VNC
Comment=Nur lokaler VNC-Zugriff über einen SSH-Tunnel
Exec=/usr/local/bin/ticket-display-vnc
Terminal=false
X-GNOME-Autostart-enabled=true
DESKTOP
chown "$display_user":"$group" "$home/.config/autostart/ticket-display.desktop" "$home/.config/autostart/ticket-display-vnc.desktop"
chmod 0644 "$home/.config/autostart/ticket-display.desktop" "$home/.config/autostart/ticket-display-vnc.desktop"

# Xfce unter X11 statt Wayland; LightDM greift dieses Snippet auf.
install -d -m 0755 /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-ticket-display.conf <<LIGHTDM
[Seat:*]
autologin-user=$display_user
autologin-user-timeout=0
user-session=xfce
LIGHTDM
chmod 0644 /etc/lightdm/lightdm.conf.d/50-ticket-display.conf

# systemweiter Cron-Plan: kein zusätzliches Passwort, root nur für TV/CEC.
cat > /etc/cron.d/ticket-display <<'CRON'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# Kein automatischer Gesamtneustart von Chromium um 07:44!
# Die 60-Sekunden-Erweiterung aktualisiert nur das Ticket-Tab.
# So bleiben andere Seiten/Präsentationen auch morgens unberührt.
# Montag bis Freitag 07:45: TV einschalten, sofern CEC aktiv
45 7 * * 1-5 root /usr/local/bin/ticket-display-tv on
# Montag bis Freitag 17:30: TV Standby, sofern CEC aktiv
30 17 * * 1-5 root /usr/local/bin/ticket-display-tv off
# Zustand nach Neustart wiederherstellen (nach USB-/Display-Initialisierung)
@reboot root /bin/sleep 90 && /usr/local/bin/ticket-display-tv sync
CRON
chmod 0644 /etc/cron.d/ticket-display

# Cron folgt auf Debian der System-Zeitzone.
timedatectl set-timezone Europe/Berlin
systemctl enable --now cron
systemctl enable lightdm

echo
echo "Installation abgeschlossen. Automatischer Desktop-Benutzer: $display_user."
echo "VNC-Start braucht die Passwortdatei: $home/.vnc/passwd (als $display_user per x11vnc -storepasswd anlegen)."
echo "Falls x11vnc schon per XFCE manuell gestartet wird, den alten Autostart entfernen."
echo "ticketview bleibt bis zur manuellen Freigabe/Löschung bestehen."
echo "1) Mit: sudo nano /etc/ticket-display.conf die Ticket-URL setzen."
echo "2) TV-Einschaltplan im TV konfigurieren ODER nach CEC-Test TV_CONTROL=cec setzen."
echo "3) Mit: sudo reboot neu starten."
echo "4) Prüfen: sudo ticket-display-diagnose"
echo "5) Im Ticket-Browser chrome://extensions aufrufen: Ticket Display – 60s Refresh muss aktiv sein."
echo "WICHTIG: Der reale TV-Standby und die Ticketanmeldung sind noch nicht verifiziert."
