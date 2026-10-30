# Benutzerwechsel: ticketview → cevik

Diese Datei hält den Wechsel des Anzeige-Benutzers fest. Der Tiny-PC nutzt inzwischen `cevik`; der frühere Benutzer `ticketview` wurde beim bisherigen Aufbau entfernt.

Die Schritte sind vor allem für eine Neuinstallation oder die Fehlersuche gedacht. **Auf einem funktionierenden Gerät nicht erneut Benutzer löschen oder Profile verschieben.**

## Warum der Wechsel?

Der Desktop, Chromium und x11vnc sollen unter demselben angemeldeten Benutzer laufen. Dafür verwendet das Installationsskript standardmäßig `cevik`.

Der Browser hat ein eigenes Profil unter:

~~~text
/home/cevik/.config/ticket-display-chromium
~~~

Die alten Cookies und Anmeldedaten aus `ticketview` wurden nicht automatisch übernommen. So werden Sitzungsdaten nicht unkontrolliert zwischen Benutzern kopiert.

## Was das Installationsskript macht

Die lokale Datei `/etc/ticket-display.conf` enthält gegebenenfalls:

~~~ini
DISPLAY_USER="cevik"
~~~

Wenn der Eintrag fehlt, gilt `cevik` als Standard.

Das Skript richtet den LightDM-Autologin, den Chromium-Autostart und den x11vnc-Autostart unter diesem Benutzer ein. Die vorhandene Ticket-URL und andere lokale Einstellungen bleiben beim erneuten Ausführen erhalten.

Zum Aktualisieren eines bestehenden Klons unter `/root/Ticketsystem`:

~~~bash
su -
cd /root/Ticketsystem
git pull
bash scripts/install.sh
~~~

Danach die LightDM-Einstellung ansehen:

~~~bash
grep -E 'autologin-user|user-session' /etc/lightdm/lightdm.conf.d/50-ticket-display.conf
~~~

Dort sollte `autologin-user=cevik` stehen.

## Nach einem Neustart prüfen

- Startet XFCE automatisch unter `cevik`?
- Öffnet Chromium die Ticketseite?
- Ist die Erweiterung **Ticket Display – 60s Refresh** unter `chrome://extensions` aktiv?
- Startet x11vnc aus der grafischen Sitzung?
- Existiert die Passwortdatei `/home/cevik/.vnc/passwd`?

Falls das VNC-Passwort fehlt, es **als `cevik`** lokal mit `x11vnc -storepasswd` einrichten. Nicht als root ausführen.

Doppelte VNC-Autostarts vermeiden. Die verwendete Desktop-Datei heißt `ticket-display-vnc.desktop` und liegt in `/home/cevik/.config/autostart/`.

Ob VNC an `127.0.0.1` oder an einer eigenen LAN-Adresse lauscht, hängt von `VNC_LISTEN_IP` in der lokalen Konfiguration ab. Details unter [DIRECT-VNC.md](DIRECT-VNC.md).

## Falls noch ein alter Benutzer vorhanden ist

Zuerst prüfen, ob in seinem Homeverzeichnis noch benötigte Dateien liegen. **`userdel -r` löscht das Homeverzeichnis unwiderruflich.** Einen Benutzer erst nach erfolgreichem Test des neuen Profils und nach ausdrücklicher administrativer Freigabe entfernen.

Keine Browser-Cookies, Passwörter oder internen Konfigurationen in GitHub hinterlegen.

## Sicherheit

Die automatische grafische Anmeldung ist praktisch für einen Fernseher, erhöht aber das Risiko bei physischem Zugriff auf das Gerät. Das verwendete Ticketkonto sollte möglichst nur lesen dürfen.

Keine grafischen Anwendungen als root betreiben und SSH-Zugriffe auf die nötigen Verwaltungsrechner begrenzen.
