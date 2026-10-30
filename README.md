# Ticketsystem – Ticketanzeige auf dem Fernseher

Im Büro hängt ein Fernseher, auf dem die Ticketübersicht aus N-able MSP Manager angezeigt wird. Dafür läuft ein kleiner PC mit Debian 13. Chromium öffnet die Ticketseite nach dem Anmelden automatisch im Vollbild.

Der Rechner ist bewusst einfach gehalten: Die Tickets werden im vorhandenen System verwaltet, nicht auf dem Tiny-PC. Der übernimmt nur die Anzeige. Bei Bedarf lassen sich auch andere Webseiten oder Präsentationen öffnen.

**Stand:** Die Anzeige läuft vor Ort. Einige Punkte, vor allem die automatische TV-Steuerung und der dauerhafte Betrieb zusätzlicher Fernwartungssoftware, müssen getrennt geprüft werden. Die Dokumentation beschreibt den vorhandenen Aufbau und die dafür vorgesehenen Skripte.

## Für neue Kollegen

Wer den Fernseher einfach nur benutzen möchte, findet hier die kurze Anleitung: **[Ticketanzeige im Alltag](docs/START-HIER.md)**.

## So ist das System aufgebaut

| Bereich | Umsetzung |
| --- | --- |
| Rechner | Tiny-PC mit Debian 13, XFCE und LightDM |
| Browser | Chromium, automatisch im Vollbild |
| Tickets | Vorhandene Weboberfläche von N-able MSP Manager |
| Aktualisierung | Chromium-Erweiterung für die Ticket-Registerkarte, etwa alle 60 Sekunden |
| Benutzer | `cevik` mit automatischer grafischer Anmeldung |
| Fernzugriff | SSH und x11vnc; RustDesk ist zusätzlich vorbereitet |
| Betriebszeit | Montag bis Freitag, 07:45 bis 17:30 Uhr (Europe/Berlin) |

Der Tiny-PC kann durchlaufen, auch wenn der Fernseher im Standby ist. Die geplanten Schaltzeiten bedeuten **nicht**, dass der TV in jeder Konfiguration zuverlässig ein- und ausschaltet. Das hängt vom Fernseher und der gewählten Steuerungsmethode ab.

### Fernsehsteuerung

Das Installationsskript richtet die Zeiten 07:45 und 17:30 Uhr ein. Die PC-seitigen Befehle wirken aber nur, wenn HDMI-CEC mit geeigneter Hardware tatsächlich funktioniert und `TV_CONTROL="cec"` gesetzt wurde.

Andernfalls bleibt `TV_CONTROL="none"` und die Zeitsteuerung muss am Fernseher selbst erfolgen. Bei älteren Samsung-Geräten kann der Einschalttimer auf TV statt HDMI wechseln. Das ist kein Fehler des Debian-PCs. Weitere Hinweise: [Installation](docs/INSTALLATION.md).

## Bedienung

| Was soll passieren? | So geht's |
| --- | --- |
| Ticketübersicht anzeigen | Wird nach dem Start von Chromium automatisch geöffnet |
| Zwischen Fenstern wechseln | `Alt + Tab` |
| Browser-Vollbild ändern | `F11`; alternativ Chromium-Menü → Zoom → Vollbild |
| Andere Webseite öffnen | `Strg + L`, Adresse eingeben |
| Wieder zu den Tickets | Zur Ticket-Registerkarte wechseln |
| Fernwartung | Über die eingerichtete SSH-/VNC-Verbindung; Details unter [VNC](docs/DIRECT-VNC.md) |

Die Erweiterung lädt nur die konfigurierte Ticket-Registerkarte neu. Andere Tabs und geöffnete Präsentationen bleiben davon unberührt. Wird die Ticket-URL verlassen, pausiert die Aktualisierung für diese Registerkarte. Näheres steht in [AUTO-REFRESH.md](docs/AUTO-REFRESH.md).

## Einrichtung und Updates

Die Installation ist für einen eigenen Anzeige-PC gedacht, **nicht für normale Mitarbeiter-PCs**. Das Skript richtet unter anderem den grafischen Autologin, Chromium-Autostart und die TV-Zeitsteuerung ein.

Wenn das Repository auf dem Tiny-PC unter `/root/Ticketsystem` liegt:

~~~bash
su -
cd /root/Ticketsystem
git pull
bash scripts/install.sh
reboot
~~~

Bei einem anderen Speicherort zuerst ins richtige Repository-Verzeichnis wechseln.

Die lokale Konfiguration liegt unter `/etc/ticket-display.conf`. Der Installer lässt eine bereits vorhandene Datei unverändert. Dort stehen die Ticket-URL, der Desktop-Benutzer, die TV-Methode und gegebenenfalls die IP für VNC. **Keine Passwörter oder Tokens dort oder im Repository ablegen.**

Eine vollständige Neuinstallation ist in [INSTALLATION.md](docs/INSTALLATION.md) beschrieben.

## Fernwartung

**SSH / VNC:** x11vnc zeigt denselben XFCE-Desktop, den der Fernseher anzeigt. Standardmäßig läuft es über einen SSH-Tunnel. Ein direkter VNC-Zugriff per IP ist optional möglich, aber unverschlüsselt und deshalb nur mit gezielter Firewall-Freigabe in einem freigegebenen Netz vertretbar. Die Konfiguration steht in [DIRECT-VNC.md](docs/DIRECT-VNC.md).

**RustDesk:** Ein separates Installationsskript und eine Vorlage für einen selbst betriebenen RustDesk-Server sind vorbereitet. RustDesk wird **nicht** durch den normalen Installer eingerichtet. Eine getestete RustDesk-Verbindung am Firmen-Tiny-PC ist hier noch nicht dokumentiert. Siehe [RUSTDESK.md](docs/RUSTDESK.md).

## Dokumentation

- [START-HIER.md](docs/START-HIER.md) – kurze Anleitung für Mitarbeiter
- [INSTALLATION.md](docs/INSTALLATION.md) – Debian einrichten und prüfen
- [AUTO-REFRESH.md](docs/AUTO-REFRESH.md) – 60-Sekunden-Aktualisierung
- [DIRECT-VNC.md](docs/DIRECT-VNC.md) – Fernzugriff über VNC
- [RUSTDESK.md](docs/RUSTDESK.md) – optionale RustDesk-Bereitstellung
- [TESTPLAN.md](docs/TESTPLAN.md) – Prüfung vor Ort
- [MIGRATION-CEVIK.md](docs/MIGRATION-CEVIK.md) – Dokumentation des Benutzerwechsels

Die zugehörigen Skripte liegen im Ordner [scripts](scripts). Die lokale Chromium-Erweiterung liegt unter [extension](extension).

## Betrieb und Sicherheit

Auf dem Bildschirm können Kundennamen und andere interne Informationen stehen. Deshalb muss der Standort des Fernsehers dafür geeignet sein. Für das Dashboard sollte ein eigenes Ticketkonto mit möglichst wenigen Berechtigungen verwendet werden.

Bitte keine Ticketinhalte, Login-Daten, internen Konfigurationen oder privaten Schlüssel nach GitHub hochladen. Änderungen an Firewall, Fernzugriff und Benutzerrechten gehören in die Hände der zuständigen IT.

**Noch zu prüfen bzw. vor Ort zu dokumentieren:** TV-Einschalten und HDMI-Quelle über den gesamten Arbeitstag, Verhalten bei Netzwerkverlust, Ticket-Login nach längerer Laufzeit und die tatsächliche Zuverlässigkeit des 60-Sekunden-Refreshs. Dass die Anzeige läuft, ersetzt diese Einzeltests nicht.

Für das Repository ist derzeit keine eigene Lizenzdatei hinterlegt.
