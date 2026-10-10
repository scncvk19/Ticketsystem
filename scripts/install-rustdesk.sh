#!/usr/bin/env bash
set -Eeuo pipefail

# RustDesk nur als eigenständige Fernwartungsoption auf einem dedizierten
# Debian-13-Tiny-PC installieren. Bestehende Ticketanzeige und VNC bleiben.
#
# Verifizierte offizielle RustDesk-GitHub-Release (2026-10-10):
# https://github.com/rustdesk/rustdesk/releases/tag/1.5.0
RUSTDESK_VERSION="1.5.0"
RUSTDESK_SHA256_AMD64="4e2b9701d25a7ef373f3d09bda584a37d6902f97a6ab15f2e86d4a5783e2a0ec"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Bitte als root starten: sudo bash scripts/install-rustdesk.sh" >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "Nicht unterstütztes System: /etc/os-release fehlt." >&2
  exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" != "debian" ]]; then
  echo "Dieses Skript ist ausschließlich für Debian vorgesehen." >&2
  exit 1
fi

if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
  echo "Nicht unterstützte Architektur: nur Debian amd64 (x86_64)." >&2
  exit 1
fi

if ! command -v systemctl >/dev/null 2>&1; then
  echo "Systemd fehlt. Installation abgebrochen." >&2
  exit 1
fi

echo "Installiere RustDesk ${RUSTDESK_VERSION} aus der offiziellen GitHub-Release."
echo "Die bestehende Chromium-Ticketanzeige und x11vnc werden nicht verändert."
echo "Der RustDesk-Dienst wird zum Schutz vor unbeabsichtigtem Fernzugriff"
echo "direkt nach der Paketinstallation gestoppt und deaktiviert."
echo

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl

workdir="$(mktemp -d)"
trap 'rm -rf -- "$workdir"' EXIT
filename="rustdesk-${RUSTDESK_VERSION}-x86_64.deb"
package="$workdir/$filename"
url="https://github.com/rustdesk/rustdesk/releases/download/${RUSTDESK_VERSION}/$filename"

curl --fail --location --show-error --silent --retry 3 \
  --proto '=https' --proto-redir '=https' --tlsv1.2 \
  --output "$package" "$url"

# Niemals heruntergeladenes Installationspaket ungeprüft ausführen.
printf '%s  %s\n' "$RUSTDESK_SHA256_AMD64" "$package" | sha256sum --check --status || {
  echo "SHA-256-Prüfung FEHLGESCHLAGEN – Installation abgebrochen." >&2
  exit 1
}

DEBIAN_FRONTEND=noninteractive apt-get install -y "$package"

# Ein .deb kann beim Installieren systemd-Dienste automatisch starten.
# Der Rechner darf erst nach manueller Konfiguration des Firmenservers
# für unbeaufsichtigten Zugriff erreichbar werden.
if systemctl cat rustdesk.service >/dev/null 2>&1; then
  systemctl disable --now rustdesk.service
fi

echo
echo "RustDesk ${RUSTDESK_VERSION} installiert und SHA-256 geprüft."
echo "RustDesk-Dienst: deaktiviert / gestoppt, bis die Firmenkonfiguration geprüft ist."
echo "Nächste Schritte in docs/RUSTDESK.md:"
echo "1. Internen RustDesk-ID-Server und dessen öffentlichen Schlüssel bereitstellen."
echo "2. RustDesk auf Debian und Windows auf exakt denselben Server einstellen."
echo "3. Unbeaufsichtigten Zugriff nur mit Freigabe, starken Zugangsdaten und"
echo "   passenden Netzwerkregeln aktivieren; danach Dienst bewusst einschalten."
echo "4. VNC erst nach erfolgreichem End-to-End- und Neustarttest ablösen."
