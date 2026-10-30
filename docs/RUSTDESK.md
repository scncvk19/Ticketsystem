# RustDesk für die Fernwartung

Mit RustDesk soll der Tiny-PC künftig von Windows aus fernsteuerbar sein. Anders als bei einer üblichen separaten RDP-Sitzung ist dabei derselbe XFCE-Desktop zu sehen, der auf dem Fernseher läuft.

**Stand:** Das Installationsskript und eine Vorlage für einen eigenen RustDesk-Server liegen im Repository. Ob RustDesk am Firmen-Tiny-PC bereits erfolgreich installiert und getestet wurde, ist hier nicht bestätigt. x11vnc bleibt deshalb als Rückfalllösung bestehen.

RustDesk wird nicht über den normalen Ticket-Installer installiert.

## Vor der Einrichtung

Für den Einsatz im Betrieb brauchen wir eine Freigabe der IT und einen festgelegten Zugriffsweg. Vorgesehen ist ein eigener ID-/Relayserver im Firmennetz oder über das freigegebene VPN.

Keine Passwörter, Geräte-IDs, Firmendomains oder privaten Schlüssel im Repository ablegen. Die Ticketanzeige kann personenbezogene Informationen enthalten. Fernsteuerung, Dateitransfer und Zwischenablage deshalb nur so weit erlauben, wie sie wirklich benötigt werden.

## RustDesk auf Debian installieren

Voraussetzung ist Debian auf `amd64` mit bestehender XFCE/X11-Sitzung.

Liegt der Klon unter `/root/Ticketsystem`:

~~~bash
su -
cd /root/Ticketsystem
git pull
bash scripts/install-rustdesk.sh
~~~

Das Skript lädt die festgelegte Version **1.5.0** aus der offiziellen GitHub-Release und prüft ihren SHA-256-Wert. Erst dann wird das Debian-Paket installiert.

Nach der Installation stoppt und deaktiviert das Skript den RustDesk-Systemdienst. **Achtung:** Das Debian-Paket kann den Dienst während seiner Installation kurz starten. Falls schon diese kurze Verbindung nach außen nicht erlaubt ist, den Zugriff vorab durch die Firmenfirewall oder eine isolierte Installation unterbinden.

Die Ticketanzeige, die Browser-Konfiguration und die VNC-Einstellungen werden dabei nicht verändert.

## Eigenen RustDesk-Server betreiben

Falls noch kein genehmigter Server vorhanden ist, gibt es unter [deploy/rustdesk-server](../deploy/rustdesk-server) eine Docker-Compose-Vorlage. Sie gehört auf eine **separate Server-VM**, nicht auf den Anzeige-PC.

Die beiden Komponenten:

- `hbbs` vermittelt die Verbindungen und Geräte-IDs.
- `hbbr` übernimmt bei Bedarf die Weiterleitung (Relay).

Auf dem Server mit Docker und Compose:

~~~bash
cd /pfad/zum/Ticketsystem/deploy/rustdesk-server
cp .env.example .env
nano .env
~~~

In der lokalen `.env` müssen die tatsächliche Bind-Adresse des Servers (`RUSTDESK_BIND_IP`) und sein interner, für beide Clients erreichbarer Name (`RUSTDESK_SERVER_HOST`) eingetragen werden.

Danach:

~~~bash
mkdir -p data
chmod 700 data
docker compose config
docker compose up -d
docker compose ps
~~~

Die Vorlage verwendet das festgelegte Server-Image `rustdesk/rustdesk-server:1.1.16`. Vor dem Produktiveinsatz den Versionsstand und die Herkunft des Images prüfen. Aktualisierungen bewusst durchführen und bei Bedarf per Digest pinnen.

Die Vorlage veröffentlicht die für einen normalen Clientbetrieb vorgesehenen Ports TCP **21115**, TCP/UDP **21116** und TCP **21117**. Sie sollte ausschließlich aus dem freigegebenen LAN/VPN erreichbar sein. **Keine Router-Portweiterleitung ins Internet einrichten.** Docker-Portfreigaben können Host-Firewallregeln umgehen; deshalb auch die externe Firewall prüfen.

In `data/` liegen die Serveridentität und private Schlüssel. Diesen Ordner sichern, aber **niemals nach GitHub hochladen**. Die `.gitignore` nimmt ihn ausdrücklich aus.

## Windows- und Linux-Client verbinden

Wenn der Server läuft, zuerst seinen **öffentlichen** Schlüssel auslesen:

~~~bash
cat data/id_ed25519.pub
~~~

Die Datei `id_ed25519` ohne `.pub` ist privat und darf nicht weitergegeben werden.

Auf **beiden** RustDesk-Clients unter **Einstellungen → Netzwerk → ID-/Relay-Server** denselben internen ID-Server und den öffentlichen Schlüssel (`Key`) hinterlegen. Bei Standardport 21117 kann das Relay-Feld normalerweise leer bleiben.

Die Windows-Installation erfolgt separat. Erst wenn Serveradresse, Berechtigungen und der Zugriff abgestimmt sind, wird auf Debian der Dienst für unbeaufsichtigten Zugriff aktiviert:

~~~bash
sudo systemctl enable --now rustdesk.service
systemctl is-active rustdesk.service
~~~

Ein dauerhaftes Passwort nur lokal in RustDesk setzen, nicht im Repository dokumentieren.

## Nach der Installation prüfen

- [ ] Beide Clients verwenden den genehmigten Firmenserver.
- [ ] Die Verbindung von Windows zeigt genau den Desktop am Fernseher.
- [ ] Chromium und die Ticketaktualisierung laufen weiter.
- [ ] RustDesk startet auch nach einem Neustart zuverlässig.
- [ ] Ein Server- oder Verbindungsabbruch beeinflusst die lokale Ticketanzeige nicht.
- [ ] Zugriff, Dateiübertragung und Zwischenablage sind auf das Nötigste begrenzt.

Erst danach entscheiden, ob VNC als zusätzliche Fernwartungsmöglichkeit gebraucht wird.

Wenn RustDesk stört, den Dienst stoppen:

~~~bash
sudo systemctl disable --now rustdesk.service
~~~

Das entfernt RustDesk nicht. Die bisherige Ticketanzeige und x11vnc werden dadurch nicht umgestellt.

Weitere Hinweise in der [offiziellen RustDesk-Dokumentation](https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/).
