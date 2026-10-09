# Ticketsystem – TV-Anzeige mit Tiny-PC

Eine schlanke, lokal betriebene **Ticketanzeige im Browser**. Ein Debian-Tiny-PC zeigt das vorhandene Ticketsystem werktags auf einem Fernseher an. Andere Webseiten und Präsentationen können über den XFCE-Desktop geöffnet werden.

> **Projektstand (09.10.2026):** Debian/Tiny-PC wurde vor Ort eingerichtet. Die neue 60-Sekunden-Erweiterung ist im Repository implementiert, aber auf der Maschine noch **nicht** getestet. TV/CEC, Login und Ticket-Refresh müssen separat geprüft werden. Dieses Repository enthält **keine** Ticketdaten oder Zugangsdaten.

## Gewünschter Betrieb

| Eigenschaft | Vorgabe |
|---|---|
| Anzeige | Montag–Freitag, **07:45–17:30 Uhr** (Europe/Berlin) |
| Samstag/Sonntag | TV aus / Standby |
| Tiny-PC | bleibt eingeschaltet; startet nach Stromausfall wenn BIOS entsprechend eingestellt |
| Betriebssystem | Debian 13 + XFCE (X11) + LightDM |
| Browser | Chromium, automatischer Vollbildstart und 60-Sekunden-Refresh nur des Ticket-Tabs |
| Ticketseite | vorhandener Webserver, URL vor Ort eintragen |
| Andere Inhalte | F11 für Desktop-/Browser-Nutzung, Alt+Tab für andere Anwendungen |
| TV-Steuerung | TV-interner Wochenplan **oder** HDMI-CEC bei kompatibler Hardware |

## Einrichten / bereits installierten Tiny-PC aktualisieren

Wenn Debian und das Repository bereits installiert sind, genügt:

```bash
cd ~/Ticketsystem  # oder der tatsächlich verwendete Klon-Pfad
git pull
sudo bash scripts/install.sh
sudo reboot
```

Wenn das Repository als root unter `/root/Ticketsystem` liegt: `su -`, dann `cd /root/Ticketsystem`, `git pull`, `bash scripts/install.sh` und `reboot`.

**Wichtig:** Die Datei `/etc/ticket-display.conf` mit deiner bereits eingetragenen Ticket-URL wird vom Installer **nicht** überschrieben. Die Browser-Erweiterung wird beim Anmelden automatisch aus dieser URL konfiguriert. Funktion überprüfen: `chrome://extensions` → **Ticket Display – 60s Refresh**. Siehe [Autorefresh-Dokumentation](docs/AUTO-REFRESH.md).

## Erstinstallation – Schnellweg

1. Debian 13 mit **XFCE** auf dem Tiny-PC installieren; LAN anschließen, Uhrzeit/Zeitzone prüfen.
2. Repo klonen (bei privatem Repository Anmeldung über GitHub/SSH erforderlich):

   ```bash
   sudo apt update && sudo apt install -y git
   git clone https://github.com/scncvk19/Ticketsystem.git
   cd Ticketsystem
   ```

3. Installer auf einem **dedizierten** Anzeige-PC ausführen:

   ```bash
   sudo bash scripts/install.sh
   ```

   Er installiert benötigte Pakete, legt den unprivilegierten Benutzer `ticketview` an, aktiviert dessen automatische grafische Anmeldung und richtet den Browser-Autostart und die Cron-Zeiten ein. Vorhandene `/etc/ticket-display.conf` wird **nicht überschrieben**.

4. Ticket-URL in der lokalen Konfiguration anpassen (**keine Zugangsdaten in die URL schreiben**):

   ```bash
   sudo nano /etc/ticket-display.conf
   # TICKET_URL="https://tickets.beispiel.intern"
   ```

5. Die TV-Variante auswählen:

   - **TV-eigener Wochen-Zeitplan**: `TV_CONTROL="none"` belassen und im Fernseher Mo–Fr 07:45 ein / 17:30 aus konfigurieren. Achtung: Manche TVs können nur Abschalt-, aber keinen täglichen Einschaltplan.
   - **HDMI-CEC**: nur bei nachweislich funktionierendem CEC-Adapter und aktivierter TV-CEC-Funktion `TV_CONTROL="cec"` einstellen. Tests: `sudo ticket-display-tv status`, `sudo ticket-display-tv on`, `sudo ticket-display-tv off`.

6. Neustarten und testen:

   ```bash
   sudo reboot
   # nach Anmeldung/über SSH:
   sudo /usr/local/bin/ticket-display-diagnose
   ```

**Vor der Installation:** Der Installer richtet *absichtlich* einen automatischen Login ohne Passwortabfrage für die lokale Anzeige ein. Darum nur auf einem dafür vorgesehenen PC verwenden und das Ticketkonto auf minimale Leseberechtigungen begrenzen.

## Tägliches Verhalten

- Nach jedem Boot startet der Browser automatisch mit der Ticketseite, auch wenn der TV gerade aus ist.
- **Alle 60 Sekunden** wird ausschließlich die konfigurierte Ticket-Registerkarte neu geladen, sofern sie noch die Ticket-URL anzeigt. Andere Tabs werden nicht angefasst.
- Kein automatischer Browser-Gesamtneustart um 07:44 mehr; damit bleiben andere Inhalte ungestört. Nach einem PC-Neustart startet das Ticket-Fenster wieder mit der Ticketseite.
- Um **07:45** wird per CEC der Fernseher eingeschaltet, falls CEC aktiviert ist.
- Um **17:30** geht er per CEC in Standby, falls CEC aktiviert ist.
- Beim Systemstart gleicht die Steuerung nach kurzer Verzögerung den TV-Zustand mit der Uhrzeit ab.
- Bei `TV_CONTROL=none` arbeitet die PC-Zeitsteuerung ohne aktive TV-Schaltsignale; in diesem Fall muss die Zeitsteuerung des TVs selbst funktionieren.

Die TV-Steuerung via HDMI-CEC ist **hardwareabhängig**; ein gewöhnlicher Tiny-PC-HDMI-Anschluss beherrscht CEC nicht unbedingt. Ein unterstützter USB-HDMI-CEC-Adapter kann erforderlich sein. Das Abschalten eines HDMI-Signals bedeutet bei Fernsehern nicht zwangsläufig Standby.

## Bedienung

| Zweck | Bedienung |
|---|---|
| Normale Ticketanzeige | nach Anmeldung automatisch im Vollbild |
| Andere Webadresse aufrufen | **F11** (Vollbild verlassen), **Strg+L**, URL eingeben |
| Präsentation anzeigen | **Alt+Tab** oder Chromium minimieren; Datei/Programm am XFCE-Desktop öffnen |
| Tickets wieder anzeigen | Zum Ticket-Tab wechseln oder konfigurierte Ticket-URL wieder aufrufen; nach PC-Neustart startet sie automatisch |
| Manuell TV schalten (CEC) | `sudo ticket-display-tv on` / `sudo ticket-display-tv off` |
| Sofort Ausgangszustand prüfen | `sudo ticket-display-tv sync` |

## Dokumentation und Dateien

- [Installation und Konfiguration](docs/INSTALLATION.md)
- [Checkliste / Funktionstest](docs/TESTPLAN.md)
- [Konfigurationsvorlage](config/ticket-display.conf.example)
- [Installer](scripts/install.sh)
- [Browser-Session](scripts/browser-session.sh)
- [Autorefresh – Bedienung, Tests und Grenzen](docs/AUTO-REFRESH.md)
- [Chromium-Erweiterung](extension/background.js)
- [Manueller Browser-Neustart (nicht zeitgesteuert)](scripts/refresh-browser.sh)
- [TV-Steuerung](scripts/tv-control.sh)
- [Diagnose](scripts/diagnostics.sh)

## Sicherheit

- Keine Passwörter, Session-Cookies, Tokens, Screenshots oder personenbezogenen Ticketdaten in GitHub speichern.
- Eigenes, eingeschränktes Ticket-Anzeigekonto mit *Leserechten* und nur den nötigen Projekten/Queues benutzen.
- Interne HTTPS-Seite und gültiges Zertifikat verwenden; Zertifikatsprüfung nicht abschalten.
- Fernzugriff nur über das interne Netz/VPN; keine öffentliche Freigabe des TVs oder Tiny-PCs.
- Falls das Ticketsystem personenbezogene Informationen anzeigt, Standort/Sichtschutz sowie betriebliche Datenschutzvorgaben beachten.
- Für sensible Umgebungen ist ein passwortloser Display-Login nur dann sinnvoll, wenn die lokale physische Zugriffssituation kontrolliert ist.

## Noch offen (beim Einrichten ausfüllen)

- [ ] Name/Modell des Tiny-PCs und TV-Modell
- [ ] Ticket-URL, Authentifizierung und gewünschter Dashboard-/Filterlink
- [ ] TV-CEC-Verfügbarkeit oder funktionierender TV-Wochenplan
- [ ] Netzwerkkonnektivität, DNS, Zertifikate, Bildschirmauflösung
- [ ] 60-Sekunden-Refresh der Ticket-Registerkarte und ungestörter Wechsel auf andere Inhalte auf dem Tiny-PC getestet
- [ ] Umgang mit Login-Timeout und Ticketanzeige beim Netzwerkausfall

Lizenz: vorerst keine gesetzt. Das Projekt ist zunächst eine interne Bereitstellungs- und Dokumentationsvorlage.
