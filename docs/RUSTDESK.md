# RustDesk-Fernwartung für die Ticketanzeige (Debian 13 ↔ Windows)

**Ziel:** Den bereits laufenden **XFCE/X11-Desktop auf dem Fernseher** von Windows aus fernsteuern, statt eine separate RDP-Sitzung zu öffnen. Die vorhandene Chromium-Ticketanzeige (inkl. 60-Sekunden-Refresh), LightDM-Anmeldung sowie x11vnc bleiben zunächst bestehen.

> **Stand:** Bereitstellung im GitHub-Repository vorbereitet, **nicht** auf dem Firmen-Tiny-PC installiert oder dort getestet. Die Windows-Installation erfolgt separat durch den Administrator.

## Grundsätze für den Arbeitsplatz

1. **Vor der Bereitstellung** klären, ob die betriebliche IT die Software, Fernzugriff auf Ticketdaten und ggf. einen eigenen Relay-/ID-Server erlaubt. Schutzbedarf und Datenschutz beachten.
2. **Kein öffentlicher RustDesk-Vermittlungsserver für den Produktivbetrieb**: nur firmeneigener Server im LAN/VPN oder eine andere ausdrücklich genehmigte Infrastruktur.
3. **Keine festen Passwörter, IDs, Schlüssel oder Firmen-IP-Adressen im GitHub-Repository** hinterlegen. RustDesk-Passwort und Server-Key ausschließlich lokal/vertraulich verwalten.
4. **x11vnc noch nicht entfernen.** Nach der RustDesk-Installation zunächst eine funktionierende Fernverbindung inklusive Neustart testen.
5. RustDesk ist ein separates Paket: der vorhandene `scripts/install.sh` installiert es **nicht** automatisch und verändert weder RustDesk noch die bestehenden Ticket-Funktionen.

## A. Linux-Client auf dem Ticket-Tiny-PC installieren

Voraussetzungen: Debian 13 `amd64`, bestehende grafische XFCE/X11-Sitzung, root-/sudo-Rechte, HTTPS-Zugang zu den offiziellen GitHub-Releases.

Im Terminal auf Debian:

```bash
su -
cd /root/Ticketsystem
git pull
bash scripts/install-rustdesk.sh
```

Falls das Repository woanders liegt, diesen Pfad entsprechend ersetzen.

Der Installer:

- lädt ausschließlich die bekannte, offizielle **RustDesk-Release 1.5.0** (`rustdesk-1.5.0-x86_64.deb`);
- prüft den fest hinterlegten **SHA-256** vor der Installation;
- verwendet `apt-get`, um die Paketabhängigkeiten korrekt zu installieren;
- **stoppt und deaktiviert unmittelbar nach der Installation** den RustDesk-Systemdienst, damit unbeaufsichtigter Zugriff erst nach Freigabe und Serverkonfiguration eingeschaltet wird;
- ändert **keine** Ticket-Konfiguration, Browser-Autostarts, Fernsehzeiten, VNC- oder UFW-Regeln.

Hinweis: Der Paketinstaller kann einen Dienst beim Installieren kurzzeitig starten; wer jede mögliche Verbindung zu öffentlichen RustDesk-Servern unterbinden muss, sollte den Netzwerkzugriff vorher über die Unternehmensfirewall sperren oder ein freigegebenes, isoliertes Installationsverfahren nutzen.

**Paketversion aktualisieren:** Bei einer neuen RustDesk-Version müssen Release-URL, Version und SHA-256 gemeinsam anhand der offiziellen Release-Daten überprüft und im Skript geändert werden. Nicht einfach `latest` ungeprüft ausführen.

## B. Firmeninternen RustDesk-Server bereitstellen (optional, aber empfohlen)

Falls es noch **keinen** freigegebenen RustDesk-ID-/Relayserver gibt, ist unter [`deploy/rustdesk-server/compose.yaml`](../deploy/rustdesk-server/compose.yaml) eine Docker-Compose-Vorlage für **RustDesk Server OSS** hinterlegt.

**Den Server auf einer separaten Unternehmens-VM/einem separaten Server betreiben**, nicht auf dem Ticket-Tiny-PC. Die Vorlage ist nicht automatisch gestartet. Sie verwendet die beiden offiziellen RustDesk-Server-Komponenten:

- `hbbs`: ID-/Vermittlungsserver
- `hbbr`: Relayserver

Auf der **Server-VM**, nach Installation von Docker Engine und Compose:

```bash
cd /pfad/zum/Ticketsystem/deploy/rustdesk-server
cp .env.example .env
nano .env
```

`RUSTDESK_BIND_IP` = **tatsächlich auf der Server-VM vorhandene** IPv4-Adresse im Firmen-LAN/VPN (nicht `0.0.0.0`, nicht die Beispiel-IP).

`RUSTDESK_SERVER_HOST` = interner DNS-Name oder IP, der/die für **beide** Clients erreichbar ist, z. B. der Name des Firmen-Servers; bei Relay dieselbe Adresse verwenden.

Dann auf der Server-VM:

```bash
mkdir -p data
chmod 700 data
docker compose config
docker compose up -d
docker compose ps
```

**Wichtige technische Hinweise:**

- Compose verwendet derzeit das offizielle Image `rustdesk/rustdesk-server:latest`; **vor dem produktiven Rollout Version/Image-Digest prüfen und für reproduzierbare Updates pinnen**. `latest` ist für eine produktive Langzeitbereitstellung allein nicht ausreichend.
- Docker-Publishing von Ports kann Host-Firewall-/UFW-Regeln umgehen. Die Adresseinschränkung aus `.env` und **zusätzlich** die zentrale Firewall/VPN-Richtlinie kontrollieren.
- Nur für die genehmigten Windows-/Linux-Clients über internes LAN oder VPN erreichbar machen, **keine Internet-Portweiterleitung**.
- Ohne Webclient benötigt der Server laut Dokumentation normalerweise TCP **21115**, TCP/UDP **21116**, TCP **21117**. TCP 21118/21119 (Webclients) sind in unserer Vorlage **nicht** veröffentlicht. Weitere Zugriffe und Optionen nach Bedarf und Sicherheitsfreigabe prüfen.
- `data/` ist persistent, enthält auch die **private Serveridentität**. Sichern, Backup verschlüsseln, Zugriff einschränken und **niemals nach GitHub pushen**.
- Öffentlichen Serversignaturschlüssel nach dem ersten Start lokal abrufen:

  ```bash
  cat data/id_ed25519.pub
  ```

  Diesen **öffentlichen** Schlüssel auf beiden RustDesk-Clients im Feld `Key` konfigurieren. `id_ed25519` **ohne** `.pub` ist privat und darf niemals geteilt werden.

Dokumentation: [Offizielles Docker-Setup](https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/) und [Clientkonfiguration](https://rustdesk.com/docs/en/self-host/client-configuration/).

## C. RustDesk auf Linux und Windows konfigurieren

Auf **beiden** Rechnern in RustDesk über **Einstellungen → Netzwerk → ID-/Relay-Server**:

1. **ID Server**: interne Firmenserver-Adresse (`RUSTDESK_SERVER_HOST`, gegebenenfalls mit Port `21116`).
2. **Key**: Inhalt der `id_ed25519.pub` des Firmenservers.
3. **Relay Server**: kann nach offizieller Dokumentation meist leer bleiben, solange Standardport `21117` und derselbe Server verwendet werden.
4. Verbindung zum Firmenserver prüfen; nicht auf einen öffentlichen Server zurückfallen lassen.

Die Windows-Version installierst und konfigurierst du selbst. Auf Debian die RustDesk-Anwendung aus dem XFCE-Anwendungsmenü öffnen und dieselbe Serveradresse/Key setzen.

**Unbeaufsichtigter Zugriff** darf erst nach Freigabe aktiviert werden. Festes Zugangspasswort nur lokal in der RustDesk-Oberfläche setzen, stark und individuell wählen, niemals hier dokumentieren. Berechtigungen (Dateiübertragung, Clipboard, Rechte zur Steuerung) auf das erforderliche Minimum reduzieren.

Erst **nach** gültiger Server-/Clientkonfiguration und IT-Freigabe den RustDesk-Dienst auf Debian bewusst aktivieren:

```bash
sudo systemctl enable --now rustdesk.service
systemctl is-active rustdesk.service
```

Prüfen, ob die **tatsächlich angezeigte** RustDesk-ID des Tiny-PCs von Windows aus erreicht werden kann und dabei genau derselbe XFCE-Desktop wie auf dem Fernseher erscheint. Die laufende Ticketanzeige darf davon nicht unterbrochen werden.

## D. Abnahme / Rollback

- [ ] Zustimmung zur Fernwartung und Sichtbarkeit von Ticketdaten eingeholt
- [ ] RustDesk-Paketversion und SHA-256 erfolgreich geprüft
- [ ] Nur den genehmigten Firmen-RustDesk-Server auf **beiden** Clients eingetragen, Key geprüft
- [ ] Verbindung von Windows zeigt denselben XFCE-Desktop wie HDMI-TV
- [ ] Chromium bleibt im Vollbild, 60-Sekunden-Refresh funktioniert
- [ ] Fernverbindung ohne Flackern und ohne unbeabsichtigte Anzeigeunterbrechung
- [ ] Nach **Neustart des Tiny-PCs** Fernzugriff verfügbar, Ticketanzeige automatisch sichtbar
- [ ] Netz-/Serverausfall simuliert: Ticketanzeige lokal weiter nutzbar
- [ ] Erst danach entscheiden, ob x11vnc noch als Fallback benötigt wird

**Rollback**, falls RustDesk stört:

```bash
sudo systemctl disable --now rustdesk.service
```

Damit wird der RustDesk-Dienst gestoppt; **x11vnc und die Ticketanzeige bleiben unverändert**. Die Software kann für einen späteren Versuch installiert bleiben.

**Wichtig:** Das GitHub-Repository stellt Skripte und Dokumentation bereit. Es richtet *keinen* Arbeitsplatzrechner von allein ein und startet *keinen* RustDesk-Server automatisch.

## Warum nicht einfach xrdp?

Das übliche `xrdp`-Setup startet eine **zusätzliche** Sitzung. Bei der Ticketanzeige möchten wir gerade die sichtbare XFCE-Sitzung am Fernseher fernsteuern. Deshalb ist RustDesk für diesen Anwendungsfall geeigneter.
