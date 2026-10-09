# Checkliste für die Umsetzung

**Installationsstart:** Freitag, 09.10.2026. Die neue Browser-Erweiterung muss nach Update und Neustart separat getestet werden.  
**Betriebszeiten:** Montag–Freitag, 07:45–17:30 Uhr (Europe/Berlin).  
**Status:** Installation/Tests auf echter Hardware noch offen.

## Vorbereitung

- [ ] Tiny-PC, TV und HDMI-Kabel vorhanden
- [ ] PC per LAN im richtigen Netzwerk, DNS und Ticket-Webserver erreichbar
- [ ] Debian 13 mit XFCE installiert
- [ ] Ticketsystem-URL und gewünschtes Dashboard bekannt
- [ ] Anzeige-/Servicekonto nur mit erforderlichen Leserechten
- [ ] Firmenfreigabe für Bildschirmstandort, sichtbare Ticketdaten und Autologin geklärt

## Installation

- [ ] Repo geklont
- [ ] `sudo bash scripts/install.sh` erfolgreich
- [ ] `TICKET_URL` in `/etc/ticket-display.conf` gesetzt
- [ ] `sudo reboot` durchgeführt
- [ ] cevik automatisch angemeldet, Chromium startet mit Ticket-URL
- [ ] VNC-Passwortdatei für cevik vorhanden und Server nur über 127.0.0.1:5900 erreichbar
- [ ] Windows SSH-Tunnel und TightVNC Viewer funktionieren
- [ ] Alte x11vnc-Autostart-Regel deaktiviert
- [ ] ticketview erst nach erfolgreichem Test samt Profil gelöscht
- [ ] Login in Ticketansicht funktioniert und Session läuft stabil
- [ ] F11, Strg+L, Alt+Tab und Wechsel auf andere Inhalte funktionieren

## TV-Steuerung (eine Variante genügt)

- [ ] TV-interner Einschalt- und Standby-Zeitplan Mo–Fr möglich und eingestellt
- [ ] **ODER** kompatibles CEC-Gerät erkannt (`sudo ticket-display-tv status`)
- [ ] **ODER** passende Hardwarelösung wird nach der Erprobung festgelegt
- [ ] TV geht wirklich in Standby, nicht bloß „Kein Signal“
- [ ] TV startet nach Standby und zeigt den richtigen HDMI-Eingang

## Automatik und Fehlersituationen

- [ ] Ticketseite wird ungefähr alle 60 Sekunden automatisch neu geladen
- [ ] In einem zweiten Tab geöffnete Webseite bleibt dabei unberührt
- [ ] Ticket-Tab auf andere URL navigieren: keine automatische Aktualisierung dieser anderen Seite
- [ ] Ticket-Tab zur konfigurierten URL zurückführen: Aktualisierung setzt wieder ein
- [ ] Kein unerwünschter Browser-Gesamtneustart um 07:44
- [ ] Zeitpunkt 07:45: TV ist eingeschaltet (werktags)
- [ ] Zeitpunkt 17:30: TV im Standby (werktags)
- [ ] Sa/So keine automatische Einschaltung
- [ ] Neustart während Betriebszeit: Ticketseite wieder sichtbar
- [ ] Neustart nach 17:30 oder am Wochenende: TV bleibt/kehrt in Standby
- [ ] Stromausfall simuliert und BIOS Power Restore geprüft
- [ ] Netzwerkunterbrechung und Wiederausbau der Verbindung getestet
- [ ] Ticketdaten aktualisieren sich zuverlässig (appseitig/Reload)
- [ ] Login-Timeout und mögliche Wiederanmeldung geklärt
- [ ] Sicherheitsupdates und Wartungszuständigkeit vereinbart

## Vor-Ort-Ergebnisse (manuell ergänzen)

| Prüfung | Ergebnis / Bemerkung |
|---|---|
| Tiny-PC | Offen |
| TV-Modell | Offen |
| Ticketsystem-URL | Nur lokal dokumentieren, falls intern |
| TV-Methode (Wochenplan/CEC) | Offen |
| Netzwerk/DNS | Offen |
| Browser-Login | Offen |
| Bildauflösung und Skalierung | Offen |
| Verantwortlich | Offen |

**Keine internen Zugangsdaten, Token oder personenbezogenen Ticketinhalte ins Repository committen.**
