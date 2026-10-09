# Installationsanleitung – Debian 13 / XFCE

## Voraussetzungen und Grenzen

- Dedizierter Tiny-PC (beliebige geeignete x86-64-Hardware, mindestens 4 GB RAM; empfohlen 8 GB).
- Debian 13 mit XFCE und X11. **Nicht** auf einem bereits anders genutzten Arbeitsplatz installieren: Der Installer richtet automatische Anmeldung ein.
- TV über HDMI/DisplayPort-Adapter angeschlossen; bevorzugt LAN-Verbindung zum bestehenden Ticketsystem.
- Ein internes, möglichst eingeschränktes Ticketkonto für die Bildschirmansicht.
- Optional TV mit **wöchentlichem Ein-/Ausschaltplan** oder ein nutzbarer **HDMI-CEC-Adapter**. Normale PC-HDMI-Buchsen unterstützen CEC oft nicht.
- Administratorzugang zum neuen PC. Bei privatem Repository Zugriff auf GitHub mittels Anmeldung oder eingerichtetem SSH-Schlüssel.

**Das Projekt hostet kein eigenes Ticketsystem.** Es zeigt nur eine vorhandene Webanwendung an.

## 1 – Betriebssystem installieren

1. Debian-13-ISO von debian.org beschaffen; ISO auf USB-Stick schreiben, davon booten.
2. Bei Desktop-Auswahl **XFCE** statt GNOME wählen (LightDM/X11).
3. Netzwerkkabel verbinden. Für einen dedizierten TV-PC einen lokalen Administrator anlegen.
4. Nach Installation einmal grafisch anmelden, Internet/Intranet und die Ticket-URL im Browser testen.
5. Falls BIOS vorhanden: `Power on after AC loss` / `Restore after power loss` auf Ein (nur wenn gewünscht).

## 2 – Repository und Installer

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/scncvk19/Ticketsystem.git
cd Ticketsystem
sudo bash scripts/install.sh
```

Das Skript:
- installiert XFCE/LightDM/Chromium/cron/cec-utils und Python zur lokalen Extension-Konfiguration;
- erstellt `ticketview` (kein sudo, ausschließlich Anzeige);
- erstellt `/etc/ticket-display.conf` **nur wenn noch nicht vorhanden**;
- installiert Programme unter `/usr/local/bin/ticket-display-*` und die lokale Chromium-Extension unter `/usr/local/share/ticket-display/extension`;
- richtet einen XFCE-Autostart und das LightDM-Autologin ein;
- installiert Cron-Jobs für Mo–Fr sowie für Neustarts;
- stellt die Systemzeitzone auf **Europe/Berlin**.

Es setzt weder Ticket-URL noch Ticket-Zugangsdaten automatisch auf ein echtes System.

## 3 – Lokale Einstellungen

```bash
sudo nano /etc/ticket-display.conf
```

Beispiel:
```bash
TICKET_URL="https://mein-ticketserver.intern/dashboard"
TV_CONTROL="none"
```

**Keine Credentials in URL, Datei oder Repository eintragen.** Login/Session im Browser des Anzeige-Benutzers einrichten; bevorzugt ein dediziertes Read-only-Konto. Bei SSO/MFA die organisatorische Freigabe und Sitzungsdauer prüfen. Niemals HTTPS-Zertifikatswarnungen umgehen.

## 4 – Fernsehervariante festlegen

### A: TV-eigener Wochenplan – zunächst bevorzugt

`TV_CONTROL="none"` beibehalten. Im TV-Menü (falls unterstützt):
- Mo–Fr **07:45 EIN**
- Mo–Fr **17:30 AUS / Standby**
- Sa/So keine Einschaltung
- Standard-/letzten HDMI-Eingang nutzen und Energiespar-, Auto-Off- und Werbe-/Startbildschirm-Einstellungen überprüfen

**Nicht jeder Fernseher kann automatisch einschalten**; ein einfacher Sleep-Timer reicht nicht. Ist das nicht möglich, Variante B prüfen.

### B: HDMI-CEC – wenn Hardware geeignet

TV-seitig HDMI-CEC einschalten (Herstellernamen z. B. Anynet+, Simplink, Bravia Sync).
CEC am Tiny-PC prüfen:
```bash
sudo ticket-display-tv status
```

Wenn kein Gerät erkannt wird, heißt das häufig: eingebauter HDMI-Port hat **keine** CEC-Funktion. Dann geeigneten USB-HDMI-CEC-Adapter verwenden oder Variante A wählen.

Nur wenn CEC verfügbar ist:
```bash
sudo nano /etc/ticket-display.conf
# TV_CONTROL="cec"
sudo ticket-display-tv on
sudo ticket-display-tv off
sudo ticket-display-tv sync
```

**Erst prüfen, dann automatisieren!** TV muss wirklich ausschalten und wieder einschalten. Adapter, HDMI-Eingang, Fernsehermodell und CEC-Konfiguration entscheiden über das Ergebnis.

### Nicht als TV-Abschaltung missverstehen

`xset dpms force off` / Ausschalten des HDMI-Signals kann bei Fernsehgeräten einfach zu **„Kein Signal“** führen, ohne echten Standby. Deshalb in diesem Projekt nicht als verlässliche TV-Abschaltung verwendet.

## 5 – Neustart und Browser

```bash
sudo reboot
```

Anschließend meldet LightDM `ticketview` automatisch an, XFCE lädt die Autostart-Datei und Chromium wird im **Vollbild** geöffnet.

Im Chromium die Ticketanmeldung einmalig vornehmen, sofern nötig. Kein Speichern von Klartext-Passwörtern oder Zugangsdaten im Repo.

Bedienung:
- F11: Vollbild ein/aus
- Strg+L: andere Webadresse
- Alt+Tab: andere geöffnete Anwendung
- Fenster minimieren: Zugriff auf XFCE-Desktop

Der Browser wird nach einem manuellen Schließen oder Absturz wieder geöffnet. Das Startskript deaktiviert zusätzlich X11-Leerlauf-Abdunkelung via `xset`. **Unbedingt** in XFCE unter Einstellungen → Energieverwaltung und Bildschirmschoner prüfen, dass kein automatisches Sperren, Suspendieren oder Abschalten innerhalb des Anzeigezeitraums greift.

### Automatischer Seiten-Refresh

Eine lokale Chromium-Extension aktualisiert **nur das registrierte Ticket-Tab** im Abstand von **60 Sekunden**; andere Tabs oder Desktop-Programme bleiben unangetastet. Wenn du im Ticket-Tab zu einer anderen URL wechselst, wird dieses nicht neu geladen. Der separate automatische Browser-Gesamtneustart um 07:44 wurde bewusst entfernt. Nach einem vollständigen Neustart des Tiny-PCs öffnet sich das Ticketsystem erneut automatisch.

Prüfen: `chrome://extensions` öffnen. Die Erweiterung **Ticket Display – 60s Refresh** muss aktiv sein. Alle Einzelheiten und Testfälle stehen unter [AUTO-REFRESH.md](AUTO-REFRESH.md).

## 6 – Zeitsteuerung

Nach der Installation liegt der Zeitplan in `/etc/cron.d/ticket-display`:

| Zeit | Tage | Aktion |
|---|---|---|
| alle ca. 60 Sekunden | solange Chromium läuft | nur die Ticketseite neu laden, per lokaler Erweiterung |
| 07:45 | Mo–Fr | TV einschalten (nur CEC) |
| 17:30 | Mo–Fr | TV Standby (nur CEC) |
| beim Systemstart | alle Tage | TV-Zustand nach ca. 90 Sekunden angleichen (nur CEC) |

**Wichtig:** `cron` arbeitet nach der lokalen **Systemzeitzone**; der Installer stellt Europe/Berlin ein. Sommer-/Winterzeitumstellung berücksichtigen. Ist das Gerät am Schaltzeitpunkt vollständig ausgeschaltet, kann Cron den Termin nicht nachholen; deshalb den Tiny-PC durchlaufen lassen. Der Boot-Abgleich greift nach einem Neustart.

Schneller Test für den jeweils aktuellen Zeitpunkt:
```bash
sudo ticket-display-tv sync
sudo ticket-display-diagnose
```

Bei TV-eigenem Zeitplan (`TV_CONTROL=none`) sendet der Tiny-PC keine TV-Befehle. Die Schaltzeiten müssen dann **am Fernseher selbst** eingestellt werden.

## 7 – Typische Fehler

| Symptom | Prüfen |
|---|---|
| Nach Boot Login-Bildschirm | LightDM aktiv? `systemctl status lightdm`; `/etc/lightdm/lightdm.conf.d/50-ticket-display.conf` |
| Browser startet nicht | XFCE-X11-Sitzung? `~/.config/autostart/ticket-display.desktop`, URL valide? Als `ticketview` prüfen |
| Browser zeigt alte Inhalte | `chrome://extensions` prüfen; `TICKET_URL` muss exakt zur geöffneten Ticketseite passen; siehe [AUTO-REFRESH.md](AUTO-REFRESH.md) |
| Browser zeigt Login-Seite | Ticketkonto/Session-TTL/SSO/MFA klären; keine Authentifizierung umgehen |
| TV zeigt „Kein Signal“ statt Standby | Kein TV-Standby; TV-Wochenplan oder CEC nutzen |
| `cec-client -l` ohne Gerät | Adapter nicht vorhanden/inkompatibel; HDMI-Port allein oft unzureichend |
| Bildschirm geht während Dienstzeit aus | XFCE-Bildschirmschoner, Sperre, TV-Auto-Abschaltung und HDMI-Quelle kontrollieren |
| Nach Stromausfall kein Ticketbild | BIOS Power Restore, Netz, LightDM, Cron, Anzeigeausgabe prüfen |
| Ticketinhalt aktualisiert sich nicht | Erweiterung aktiviert? Ist die Ticketseite vollständig geladen und nicht auf `/login` umgeleitet? [AUTO-REFRESH.md](AUTO-REFRESH.md) |

## 8 – Abnahme und Übergabe

Alle Punkte der [Testcheckliste](TESTPLAN.md) durchgehen. Danach ggf. mit dem Betrieb IT-Sicherheitsfreigabe/Datenschutz/Sichtbarkeit und Wartungszuständigkeit klären.

**Achtung:** Die Installation ist ein realer Systemeingriff. Nicht ungeprüft auf produktiven Arbeitsplätzen ausführen. Vorhandene LightDM-Customizing-/Cron-Konfiguration vor Eingriff sichern. Sicherheitsupdates planbar einspielen; Ticket-Browserprofil lokal geschützt halten.
