#!/usr/bin/env bash
set -euo pipefail
# Neustart nur des dedizierten Ticket-Browsers. Ausführung als 'ticketview'.
if [[ "$(id -un)" != "ticketview" ]]; then
  echo "Dieses Skript nur als ticketview ausführen." >&2
  exit 1
fi
pid_file="$HOME/.local/state/ticket-display/browser.pid"
if [[ ! -r "$pid_file" ]]; then
  echo "Browser-Session noch nicht gestartet, kein Reset nötig."
  exit 0
fi
read -r pid < "$pid_file" || exit 0
if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
  # Nur ein eigener Userprozess wird signalisiert; der Session-Loop öffnet
  # anschließend wieder die konfigurierte Ticket-Startseite.
  cmdline="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)"
  if [[ "$cmdline" == *"ticket-display-chromium"* ]]; then
    kill -TERM "$pid"
    echo "Ticket-Browser für Tagesstart neu gestartet."
  else
    echo "PID gehört nicht zum Ticket-Browser; übersprungen." >&2
  fi
else
  echo "Ticket-Browser läuft noch nicht."
fi
