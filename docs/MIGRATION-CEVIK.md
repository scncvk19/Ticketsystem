# Wechsel von ticketview zu cevik

Stand: 09.10.2026. Diese Schritte **direkt am Tiny-PC** ausführen oder nur, wenn du die lokale Konsole weiterhin erreichen kannst.

**Wichtig:** Den alten Benutzer `ticketview` erst löschen, wenn die neue grafische Anmeldung und das Ticketsystem unter `cevik` geprüft wurden. Der Wechsel ist ein Eingriff in den Autologin; ein Neustart wird benötigt.

## 1. Alte Browser-Daten berücksichtigen

Die alte Chromium-Sitzung liegt bei `/home/ticketview/.config/ticket-display-chromium`. Das neue `cevik`-Profil ist bewusst unabhängig; Login und Cookies werden **nicht automatisch kopiert**, um Sitzungsdaten nicht zwischen Benutzern zu verschieben. Melde dich im neuen Profil beim Ticketsystem erneut an.

Wenn in `/home/ticketview` noch persönliche Dateien liegen, **vor** dem späteren `userdel -r` prüfen und notwendige Dateien separat sichern. Keine Zugangsdaten/Cookies ins GitHub-Repository übertragen.

## 2. Repository auf dem Debian-PC aktualisieren

Wenn das Repository ursprünglich als root nach `/root/Ticketsystem` geklont wurde:

```bash
su -
cd /root/Ticketsystem
git pull
```

Falls der Klon anderswo liegt, in dessen Verzeichnis wechseln. Den Installer auf dem **dedizierten** Anzeige-PC erneut ausführen:

```bash
bash scripts/install.sh
```

Das Skript:
- nimmt `DISPLAY_USER` aus `/etc/ticket-display.conf` (wenn noch nicht vorhanden: **cevik** als Standard);
- richtet `autologin-user=cevik` in LightDM ein;
- erstellt Browser- und VNC-Autostart in `/home/cevik/.config/autostart/`;
- erhält die vorhandene `TICKET_URL` und `TV_CONTROL` vollständig;
- installiert `x11vnc` und die lokale 60-Sekunden-Chromium-Erweiterung;
- **löscht `ticketview` nicht automatisch**.

Die neue Beispielkonfiguration enthält `DISPLAY_USER="cevik"`. Bei älteren bereits vorhandenen Config-Dateien ist kein manueller Eintrag nötig, solange du `cevik` willst.

Verifikation:
```bash
grep -E 'autologin-user|user-session' /etc/lightdm/lightdm.conf.d/50-ticket-display.conf
# Erwartet: autologin-user=cevik
```

## 3. VNC-Passwort als cevik prüfen

Wechsle **ohne root** in eine grafische Terminal-Sitzung als `cevik`. Existiert unter `/home/cevik/.vnc/passwd` noch kein VNC-Passwort:

```bash
x11vnc -storepasswd
```

Nicht als root ausführen und Passwortdatei nicht in GitHub hochladen. Der VNC-Autostart bleibt aus, wenn die Passwortdatei fehlt. Der neue VNC-Launcher nutzt das `DISPLAY` und das ggf. gesetzte `XAUTHORITY` der **cevik-XFCE-Sitzung**.

Falls du unter XFCE zuvor eine eigene Autostart-Regel für x11vnc erstellt hast, **diese alte Regel löschen/deaktivieren** (`Einstellungen → Sitzung und Startverhalten → Automatisch gestartete Anwendungen`), damit nicht zwei VNC-Server um Port 5900 konkurrieren. Die vom Installer verwaltete Regel heißt **Ticketanzeige VNC**.

## 4. Neustart

```bash
reboot
```

Danach lokal prüfen:
```bash
whoami
# cevik
ss -tln | grep ':5900'
# 127.0.0.1:5900 (eventuell auch ::1:5900)
```

Chromium muss mit der konfigurierten Ticketseite starten. Der Refresh wird unter `chrome://extensions` als **Ticket Display – 60s Refresh** angezeigt. Im Browser ggf. neu anmelden und die 60-Sekunden-Aktualisierung testen.

Der VNC-Server darf **nicht** auf `0.0.0.0:5900` oder `[::]:5900` lauschen. Er bleibt auf Loopback beschränkt.

Auf Windows:

```powershell
ssh -N -L 5901:127.0.0.1:5900 cevik@192.168.19.174
```

Im TightVNC Viewer: `127.0.0.1::5901`.

Die IP ist nur ein im Gespräch genannter Testwert und kann sich nach WLAN-Umstellung ändern. Die SSH-Client-Verbindung nur im freigegebenen lokalen Netz verwenden.

## 5. Erst jetzt ticketview entfernen

**Erst nach erfolgreichem Browser- und VNC-Test.** Als root:

```bash
su -
loginctl terminate-user ticketview
userdel -r ticketview
id ticketview
# sollte "no such user" ausgeben
```

**ACHTUNG:** `userdel -r` löscht das Homeverzeichnis `/home/ticketview` mitsamt dessen Browserprofil unwiderruflich. Vorher prüfen, ob dort noch Daten benötigt werden. `loginctl terminate-user` beendet dessen mögliche Sitzung.

Falls `userdel -r` meldet, dass der Benutzer noch verwendet wird: **nicht** mit Gewalt Dateien löschen. Zuerst mit `ps -u ticketview -f` nachsehen und Restprozesse gezielt beenden.

## 6. Sicherheits- und Betriebshinweise

- Kein Root-Browser und kein SSH-Root-Login erforderlich.
- Wenn `cevik` sudo-Rechte besitzt, ist die automatisch angemeldete Desktop-Sitzung sicherheitlich sensibler als eine reine Read-only-Kiosk-Kennung. Gerätezugang, Browseranmeldung und Ticketberechtigungen entsprechend einschränken.
- Der Browser hat ein eigenes Profil, das nicht mit dem normalen Chromium-Profil von `cevik` verwechselt werden soll.
- Kein VNC-Port 5900 in UFW freigeben; Zugriff nur über SSH-Port 22 aus dem erlaubten Netz.
- Die Fernsehzeitsteuerung und `/etc/ticket-display.conf` bleiben bei dem Wechsel erhalten.
