#!/usr/bin/env bash
set -u

echo "===== Ticket-Display: Diagnose ====="
echo "Datum/Zeit: $(date -Is)"
echo "System: $(grep PRETTY_NAME /etc/os-release 2>/dev/null | head -n 1)"
echo "Zeitzone: $(timedatectl show -p Timezone --value 2>/dev/null || echo unbekannt)"
echo "Debian-Pakete:"
dpkg-query -W -f='${binary:Package} ${Version}\n' chromium lightdm xfce4 cron cec-utils 2>/dev/null || true

echo
echo "Systemdienste:"
for service in cron lightdm; do
  echo "$service: $(systemctl is-active "$service" 2>/dev/null || true)"
done

echo
echo "Anzeige-Nutzer:"
if id ticketview >/dev/null 2>&1; then
  id ticketview
  home="$(getent passwd ticketview | cut -d: -f6)"
  if [[ -e "$home/.local/state/ticket-display/browser.pid" ]]; then
    echo "Browser PID-Datei vorhanden."
    cat "$home/.local/state/ticket-display/browser.pid"
  else
    echo "Browser PID-Datei noch nicht vorhanden."
  fi
else
  echo "ticketview fehlt."
fi

echo
echo "Konfiguration (ohne URL/Credentials):"
if [[ -r /etc/ticket-display.conf ]]; then
  grep '^TV_CONTROL=' /etc/ticket-display.conf || true
  if grep -q '^TICKET_URL="https\?://' /etc/ticket-display.conf; then
    echo "TICKET_URL gesetzt (http/https)."
  else
    echo "TICKET_URL fehlt oder ist nicht korrekt formatiert."
  fi
else
  echo "Konfiguration fehlt."
fi

echo
echo "Cron-Datei:"
if [[ -f /etc/cron.d/ticket-display ]]; then
  cat /etc/cron.d/ticket-display
else
  echo "Nicht eingerichtet."
fi

echo
echo "CEC-Geräte (nur wenn angeschlossen):"
if command -v cec-client >/dev/null 2>&1; then
  timeout 12 cec-client -l || true
fi

echo
echo "Fertig. Keine Cookies/Passwörter in Diagnoseausgaben veröffentlichen."
