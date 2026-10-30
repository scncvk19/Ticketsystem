# Fernzugriff auf den Tiny-PC mit VNC

Auf dem Tiny-PC läuft x11vnc. Damit sieht man aus der Ferne dieselbe XFCE-Sitzung, die auch auf dem Fernseher angezeigt wird.

**Standard ist VNC über SSH.** Der direkte Zugriff auf Port 5900 ist optional, aber nicht verschlüsselt. Für betriebliche Ticketdaten ist der SSH-Tunnel die bessere Wahl.

## Standard: VNC über SSH

Auf dem Windows-Rechner in PowerShell einen Tunnel zum Tiny-PC öffnen:

~~~powershell
ssh -N -L 5901:127.0.0.1:5900 cevik@<IP-des-Tiny-PCs>
~~~

Im TightVNC Viewer danach `127.0.0.1::5901` eintragen. Der Tunnel bleibt geöffnet, solange der SSH-Befehl läuft.

Auf Debian ist dafür normalerweise `VNC_LISTEN_IP="127.0.0.1"` in `/etc/ticket-display.conf` gesetzt.

## Optional: direkte Verbindung im internen Netz

Nur mit Freigabe der zuständigen IT und mit eingeschränkter Firewall-Regel verwenden.

1. Die aktuelle IPv4-Adresse des Tiny-PCs mit `ip -4 -br addr` feststellen.
2. In `/etc/ticket-display.conf` die Variable `VNC_LISTEN_IP` auf genau diese lokale IPv4-Adresse setzen.
3. Mit `ufw status numbered` die Firewall prüfen. Port **5900/tcp** nur für den festgelegten Administrationsrechner öffnen, nicht für das gesamte Netzwerk.
4. Eine feste DHCP-Zuordnung für den Tiny-PC vorsehen. Wenn seine IP wechselt, funktioniert die Einstellung nicht mehr.
5. Neu starten und danach mit `ss -tlnp | grep ':5900'` kontrollieren, ob x11vnc an der richtigen Adresse lauscht.

Bei direktem Zugriff wird im Viewer `<IP-des-Tiny-PCs>::5900` eingetragen.

Eine allgemeine UFW-Regel wie `5900/tcp ALLOW Anywhere` darf nicht stehen bleiben. Bei Docker, VPN oder mehreren Netzwerkschnittstellen zusätzlich den tatsächlichen Zugriffsweg prüfen.

## Passwort und Autostart

Die Passwortdatei gehört dem Desktop-Benutzer, standardmäßig `cevik`:

~~~bash
ls -l /home/cevik/.vnc/passwd
~~~

Falls sie fehlt, lokal als `cevik` (nicht als root) erzeugen:

~~~bash
x11vnc -storepasswd
~~~

Der XFCE-Autostart liegt unter `/home/cevik/.config/autostart/ticket-display-vnc.desktop`. Er ruft `/usr/local/bin/ticket-display-vnc` auf.

Wenn schon eine ältere VNC-Autostart-Regel eingerichtet wurde, diese deaktivieren. Zwei x11vnc-Prozesse können sich beim Zugriff auf Port 5900 gegenseitig stören.

## Wenn die Verbindung nicht klappt

~~~bash
ss -tlnp | grep ':5900'
ip -4 -br addr
~~~

Wenn kein Port angezeigt wird, die Passwortdatei und den XFCE-Autostart prüfen. Der VNC-Start benötigt eine laufende grafische Sitzung; einfaches Ausführen aus SSH ohne `DISPLAY` reicht nicht.

Falls das Bild nur im TightVNC Viewer flackert, zunächst den XFCE-Kompositor testen:

~~~bash
xfconf-query -c xfwm4 -p /general/use_compositing -s false
~~~

Der VNC-Launcher verwendet bereits `-noxdamage`. Weitere Änderungen erst nach einem Vergleich zwischen lokalem HDMI-Bild und Fernansicht vornehmen.

## Direkten Zugriff wieder entfernen

In `/etc/ticket-display.conf` wieder `VNC_LISTEN_IP="127.0.0.1"` einstellen und neu anmelden oder neu starten. Anschließend direkte Freigaben für Port 5900 in der Firewall löschen. Danach funktioniert der Zugriff wieder nur über den SSH-Tunnel.
