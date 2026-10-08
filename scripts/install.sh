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

echo "ACHTUNG: LightDM-Autologin für ticketview und werktägliche TV-Schaltzeiten werden eingerichtet."
echo "Nur auf einem dedizierten Anzeige-PC fortfahren!"
echo
echo "Installiere Debian-Pakete …"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  xfce4 lightdm lightdm-gtk-greeter xorg dbus-x11 \
  chromium chromium-l10n cron cec-utils util-linux x11-xserver-utils

if ! id ticketview >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash ticketview
fi
group="$(id -gn ticketview)"
home="$(getent passwd ticketview | cut -d: -f6)"

# Konfigurationsdatei nie überschreiben.
if [[ ! -e /etc/ticket-display.conf ]]; then
  install -m 0644 "$root/config/ticket-display.conf.example" /etc/ticket-display.conf
fi

install -m 0755 "$root/scripts/browser-session.sh" /usr/local/bin/ticket-display-browser
install -m 0755 "$root/scripts/refresh-browser.sh" /usr/local/bin/ticket-display-refresh
install -m 0755 "$root/scripts/tv-control.sh" /usr/local/bin/ticket-display-tv
install -m 0755 "$root/scripts/diagnostics.sh" /usr/local/bin/ticket-display-diagnose

install -d -m 0755 -o ticketview -g "$group" "$home/.config"
install -d -m 0755 -o ticketview -g "$group" "$home/.config/autostart"
install -d -m 0700 -o ticketview -g "$group" "$home/.local/state/ticket-display"
install -d -m 0700 -o ticketview -g "$group" "$home/.cache/ticket-display"

cat > "$home/.config/autostart/ticket-display.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Ticketanzeige
Comment=Chromium-Ticketanzeige mit Neustart bei Browserende
Exec=/usr/local/bin/ticket-display-browser
Terminal=false
X-GNOME-Autostart-enabled=true
DESKTOP
chown ticketview:"$group" "$home/.config/autostart/ticket-display.desktop"
chmod 0644 "$home/.config/autostart/ticket-display.desktop"

# Xfce unter X11 statt Wayland; LightDM greift dieses Snippet auf.
install -d -m 0755 /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-ticket-display.conf <<'LIGHTDM'
[Seat:*]
autologin-user=ticketview
autologin-user-timeout=0
user-session=xfce
LIGHTDM
chmod 0644 /etc/lightdm/lightdm.conf.d/50-ticket-display.conf

# systemweiter Cron-Plan: kein zusätzliches Passwort, root nur für TV/CEC.
cat > /etc/cron.d/ticket-display <<'CRON'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# Montag bis Freitag 07:44: Browser neu mit Ticket-URL starten
44 7 * * 1-5 ticketview /usr/local/bin/ticket-display-refresh
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
echo "Installation abgeschlossen."
echo "1) Mit: sudo nano /etc/ticket-display.conf die Ticket-URL setzen."
echo "2) TV-Einschaltplan im TV konfigurieren ODER nach CEC-Test TV_CONTROL=cec setzen."
echo "3) Mit: sudo reboot neu starten."
echo "4) Prüfen: sudo ticket-display-diagnose"
echo "WICHTIG: Der reale TV-Standby und die Ticketanmeldung sind noch nicht verifiziert."
