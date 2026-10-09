# Automatischer Refresh – 60 Sekunden

## Verhalten

Die Ticketanzeige wird **alle 60 Sekunden** durch eine lokale Chromium-Extension (Manifest V3, `chrome.alarms`) neu geladen.

- Nur die **erste passend zur lokal konfigurierten Ticket-URL gefundene Registerkarte** wird registriert und aktualisiert.
- Andere Browser-Tabs, Desktop-Programme und Präsentationen werden **nicht** neu geladen.
- Wird die registrierte Registerkarte auf eine **andere Adresse** umgestellt, pausiert das Aktualisieren. Nach Rückkehr zur exakt konfigurierten Ticketseite (inkl. Pfad und Query, ohne Hash) wird es wieder aufgenommen.
- Das Intervall läuft ab Installation / Browserstart; Timerereignisse können durch Browser-Scheduling etwas verzögert sein.
- Nach einem PC-Neustart lädt Chromium wieder die konfigurierte Ticketseite und die Extension startet automatisch.
- Login-Redirects (z. B. `/login`) werden **nicht** aktualisiert, solange sie nicht der konfigurierten Anzeige-URL entsprechen.

**Achtung:** Ein vollständiger Seiten-Reload kann lokale Filterzustände, unbeendete Formulare und vorübergehende Benachrichtigungen zurücksetzen. Die Ticketanzeige sollte deshalb im Anzeigekonto lesend und möglichst ohne Formularbearbeitung laufen. Wenn die Webanwendung bereits per WebSocket / Long Polling live aktualisiert, ist ein zusätzliches Reload möglicherweise gar nicht nötig.

## Installation auf bereits eingerichteter Debian-Maschine

Im vorhandenen lokalen Repository:

```bash
cd ~/Ticketsystem
git pull
sudo bash scripts/install.sh
sudo reboot
```

Falls das Repository bisher nur unter `/root/Ticketsystem` geklont wurde:

```bash
su -
cd /root/Ticketsystem
git pull
bash scripts/install.sh
reboot
```

Die lokale `/etc/ticket-display.conf` bleibt erhalten. Beim Start von `ticketview` wird die URL **ausschließlich auf dem Tiny-PC** in die Erweiterungskonfiguration unter `~ticketview/.local/share/ticket-display/extension/config.js` geschrieben; diese Datei wird nicht eingecheckt.

## Funktionsprüfung

1. Nach dem Boot sollte Chromium die Ticketseite öffnen.
2. In Chromium `chrome://extensions` aufrufen (bei Vollbild zuvor F11); die Erweiterung **Ticket Display – 60s Refresh** sollte erscheinen. Sie stammt aus `~ticketview/.local/share/ticket-display/extension`.
3. Zur Ticketseite zurückkehren. Bei geöffneter Ticketseite nach ungefähr einer Minute beobachten, ob eine Seitenaktualisierung erfolgt (am einfachsten im Netzwerktab der Entwicklerwerkzeuge oder durch einen sichtbaren Ladestatus).
4. In einer **zweiten Registerkarte** eine andere Webseite öffnen und Text in ein Formular schreiben. Nach über 60 Sekunden darf die zweite Seite nicht neu geladen werden.
5. Die registrierte Ticket-Registerkarte auf eine andere Webadresse ändern und mehr als eine Minute warten: die andere Seite darf **nicht** neu geladen werden.
6. Wieder zur Ticket-URL navigieren. Die automatische Aktualisierung sollte erneut einsetzen.
7. Debian neu starten und prüfen, dass die Erweiterung ohne manuelle Aktion läuft.

## Probleme beheben

| Beobachtung | Prüfen |
|---|---|
| Extension fehlt in `chrome://extensions` | `git pull`, Installer erneut ausführen, Neustart; Chromium muss mit `--load-extension` gestartet sein |
| Es findet kein Reload statt | Browserprofil der Ticketanzeige? Exakte URL inkl. Pfad/Query? Wurde auf die Login-Seite umgeleitet? |
| Es wird die falsche Seite aktualisiert | `TICKET_URL` prüfen, andere Tabs nicht auf dieselbe Ticket-URL setzen; Browser neu starten |
| Extension deaktiviert | Unter `chrome://extensions` aktivieren; Unternehmensrichtlinien können lokale Extensions untersagen |
| Anderes Fenster wird um 07:44 unterbrochen | Mit der aktuellen Installation wurde der alte automatische Browser-Gesamtneustart aus Cron entfernt; bitte neu installieren |

### Sicherheit

Die Extension nutzt nur die lokalen Chromium-APIs `tabs`, `alarms` und `storage`. Sie kommuniziert nicht mit externen Diensten und speichert **keine** Zugangsdaten. Die `tabs`-Berechtigung ist technisch breit; deshalb wird die Erweiterung ausschließlich im **separaten Ticket-Browserprofil** geladen.

**Bekannte Grenze:** Chrome-/Chromium-Richtlinien oder Distributionseinstellungen können das Laden entpackter Erweiterungen über Kommandozeilenparameter verhindern. Dann vor Ort die Extension-Aktivierung kontrollieren; der 60-Sekunden-Refresh ist ohne die aktive Erweiterung **nicht gewährleistet**.
