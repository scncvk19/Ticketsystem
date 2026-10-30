# Ticketanzeige einrichten (Debian 13)

Diese Anleitung ist für einen eigenen Anzeige-PC gedacht. Sie beschreibt die Installation aus dem Repository und die wichtigsten Prüfungen danach.

Der Installer richtet eine automatische grafische Anmeldung ein. **Nicht auf einem normalen Arbeitsplatzrechner ausführen.**

## Voraussetzungen

- Debian 13 mit XFCE und X11
- vorhandener Benutzer `cevik` (oder ein zuvor angelegter Benutzer über `DISPLAY_USER`)
- Netzwerkverbindung zum internen Ticketserver
- Fernseher am HDMI-Anschluss
- Root-Rechte für die Einrichtung

Ein TV-Ein-/Ausschaltplan ist eine eigene Aufgabe. Nicht jeder Fernseher kann automatisch auf HDMI starten.

## 1. Repository installieren

Als normaler Benutzer mit `sudo`:

~~~bash
sudo apt update
sudo apt install -y git
git clone https://github.com/scncvk19/Ticketsystem.git
cd Ticketsystem
sudo bash scripts/install.sh
~~~

Falls `sudo` nicht eingerichtet ist, über `su -` zu root wechseln und die Installation ohne `sudo` ausführen. Der Benutzer für die grafische Anmeldung muss **vorher** existieren.

Das Skript installiert unter anderem Chromium, XFCE/LightDM, x11vnc und die benötigten Hilfsprogramme. Es legt die Autostarts sowie die zeitgesteuerten TV-Befehle an.

**Achtung bei bereits eingerichteten PCs:** Der Installer schreibt die Autostart- und LightDM-Dateien neu. Vor Änderungen an anderen Geräten bestehende Konfigurationen sichern.

## 2. Ticketseite eintragen

~~~bash
sudo nano /etc/ticket-display.conf
~~~

Wichtige Einträge:

~~~ini
TICKET_URL="https://tickets.beispiel.intern"
DISPLAY_USER="cevik"
TV_CONTROL="none"
VNC_LISTEN_IP="127.0.0.1"
~~~

Die URL ist hier nur ein Beispiel. Die echte Ticketadresse wird **ausschließlich auf dem Tiny-PC** eingetragen, nicht ins GitHub-Repository.

Der Installer erstellt die Datei nur, wenn sie noch nicht vorhanden ist. Bei späteren Updates bleiben die vorhandenen Einstellungen erhalten.

## 3. Fernseher und Zeiten

Im Repository sind folgende Zeiten vorgesehen:

| Tag | Ein | Aus |
| --- | --- | --- |
| Montag–Freitag | 07:45 | 17:30 |
| Samstag/Sonntag | keine geplante Einschaltung | Standby |

Die Zeitsteuerung liegt in `/etc/cron.d/ticket-display`.

Es gibt zwei Möglichkeiten:

- **TV-eigener Zeitplan:** `TV_CONTROL="none"` lassen und Ein-/Ausschalten direkt am Fernseher einstellen.
- **HDMI-CEC:** Nur verwenden, wenn am Tiny-PC ein geeigneter CEC-Adapter vorhanden ist und der Fernseher die Befehle annimmt. Dann `TV_CONTROL="cec"` setzen.

CEC prüfen:

~~~bash
sudo ticket-display-tv status
~~~

Wenn CEC tatsächlich verfügbar ist:

~~~bash
sudo ticket-display-tv on
sudo ticket-display-tv off
~~~

Bei einigen älteren Samsung-Fernsehern lässt sich im Einschalttimer nur TV oder USB wählen, nicht HDMI. Der Browser kann korrekt laufen, während der Fernseher morgens trotzdem auf dem falschen Eingang startet. Auch eine automatische Abschaltung nach einigen Stunden muss am Gerät geprüft werden.

**Wichtig:** Ein abgeschaltetes HDMI-Signal ist nicht dasselbe wie TV-Standby.

## 4. Neustart und Browser prüfen

~~~bash
sudo reboot
~~~

Nach dem Start soll LightDM den Anzeigebenutzer automatisch anmelden. Chromium öffnet die konfigurierte Ticketseite im Vollbild.

Bei Bedarf im Chromium-Menü das Vollbild wieder einschalten. `F11` kann bei Fernwartungssoftware abgefangen werden.

Die Erweiterung zur Aktualisierung heißt **Ticket Display – 60s Refresh**. Prüfen unter `chrome://extensions`. Wie sie arbeitet, steht in [AUTO-REFRESH.md](AUTO-REFRESH.md).

Die Browser-Anmeldung erfolgt am Gerät. Keine Passwörter, Browserprofile oder Sitzungscookies ins Repository kopieren.

## 5. Fernzugriff

Für Fernwartung ist x11vnc vorgesehen. Die Verbindung zeigt den Bildschirm, der auch über HDMI ausgegeben wird.

Ab Werk bindet x11vnc an `127.0.0.1:5900`. Der Zugriff erfolgt damit über SSH-Tunneling. Eine direkte Verbindung zur Geräte-IP ist optional möglich, muss aber einzeln abgesichert werden. Alle Schritte stehen in [DIRECT-VNC.md](DIRECT-VNC.md).

RustDesk ist unabhängig davon vorbereitet, wird aber nicht durch diesen Installer installiert. Siehe [RUSTDESK.md](RUSTDESK.md).

## 6. Fehler eingrenzen

Als root oder mit `sudo`:

~~~bash
ticket-display-diagnose
systemctl status lightdm
systemctl status cron
~~~

| Problem | Prüfen |
| --- | --- |
| Login-Bildschirm statt Desktop | LightDM-Konfiguration und Benutzer |
| Chromium öffnet nicht | XFCE-Autostart, Ticket-URL, Browserprofil |
| Ticketansicht bleibt stehen | `chrome://extensions`, URL, Netzwerk und Sitzung |
| Fernseher zeigt „Kein Signal“ | HDMI-Eingang, Kabel, TV-Schaltplan |
| VNC nicht erreichbar | VNC-Passwort, Autostart, IP-Bindung und Firewall |
| Bildschirm wird dunkel | TV-Energiesparen und XFCE-Energieverwaltung |

Vor der Übergabe die [Prüfliste](TESTPLAN.md) abarbeiten. Vor allem die Zeitsteuerung und das Verhalten nach einem längeren Netzwerk- oder Stromausfall gesondert testen.

## Hinweise für den Betrieb

Die automatische Anmeldung und das gemeinsame Ticketdisplay sind nur sinnvoll, wenn Standort und Berechtigungen intern freigegeben sind. Den Ticketzugang möglichst auf eine Leseansicht beschränken.

Updates regelmäßig einspielen, Zugänge begrenzen und den Server für die Ticketanwendung getrennt administrieren. Der Tiny-PC hostet kein eigenes Ticketsystem.
