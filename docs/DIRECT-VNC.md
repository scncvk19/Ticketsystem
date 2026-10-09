# Direkter TightVNC-Zugriff über die IP-Adresse (opt-in)

**Stand 09.10.2026 – Debian 13 / XFCE / Tiny-PC**

Standard ist und bleibt der verschlüsselte SSH-Tunnel (`VNC_LISTEN_IP="127.0.0.1"`). Die hier dokumentierte direkte VNC-Verbindung ist nur für **ausdrücklich autorisierte, kontrollierte interne Netze** gedacht. Herkömmliches VNC überträgt Bildschirminhalt und Eingaben **nicht transportverschlüsselt**. Unternehmensvorgaben und Sichtbarkeit der Ticketdaten berücksichtigen; im Zweifel den SSH-Tunnel benutzen.

## Direkte Verbindung einschalten

Der Tiny-PC hat im bisher geprüften WLAN `192.168.19.174/24`. Der Windows-Administrationsrechner wurde als `192.168.19.61` beobachtet (IP vor Ort bestätigen).

Vorhandenes Repository als root aktualisieren:

```bash
su -
cd /root/Ticketsystem
git pull
```

In der lokalen Gerätekonfiguration einmalig folgende Zeile ergänzen bzw. korrigieren:

```bash
nano /etc/ticket-display.conf
```

```ini
VNC_LISTEN_IP="192.168.19.174"
```

Die vorhandene `TICKET_URL` und `TV_CONTROL` unverändert lassen.

Installer erneut ausführen:

```bash
bash scripts/install.sh
```

Der Installer überschreibt `/etc/ticket-display.conf` **nicht**. VNC startet anschließend in der grafischen Sitzung von `cevik`, wartet bei verzögertem WLAN bis zu 180 Sekunden auf die lokale Adresse, und bindet Port 5900 nur an diese IPv4. Wenn der PC nach einem Neustart eine andere IP erhält, muss `VNC_LISTEN_IP` angepasst werden; besser DHCP-Reservierung am Router setzen.

## Firewall

Vorhandene VNC-Regeln kontrollieren:

```bash
ufw status numbered
```

Nur vom bestätigten Windows-Admin-PC aus freigeben:

```bash
ufw allow from 192.168.19.61 to 192.168.19.174 port 5900 proto tcp
```

Wenn zuvor eine allgemeine Regel wie `5900/tcp ALLOW IN 192.168.19.0/24` existierte, sie **anschließend** per `ufw delete NUMMER` entfernen (vorher mit `ufw status numbered` die richtige aktuelle Nummer prüfen). Keine allgemeine Freigabe `5900/tcp ALLOW Anywhere` behalten. Auf Windows muss `192.168.19.61` weiterhin die tatsächlich verwendete Quell-IP sein; wenn nicht, Firewall-Regel entsprechend ändern.

## VNC-Passwort und doppelte Autostarts

Als `cevik` prüfen, dass `/home/cevik/.vnc/passwd` existiert:

```bash
ls -l /home/cevik/.vnc/passwd
```

Sonst als `cevik` lokal (nicht root!) mit `x11vnc -storepasswd` erzeugen.

Falls bereits ein eigenständiger XFCE-VNC-Autostart angelegt ist, diesen deaktivieren. Der Installer verwendet ausschließlich `/home/cevik/.config/autostart/ticket-display-vnc.desktop`, welcher `/usr/local/bin/ticket-display-vnc` aufruft.

## Neustart und Prüfung

```bash
reboot
```

Anschließend auf Debian (in einer neuen SSH-Verbindung):

```bash
ss -tlnp | grep ':5900'
```

Erwartet: `192.168.19.174:5900`. Auf Windows im TightVNC Viewer `192.168.19.174::5900` eingeben und das VNC-Passwort verwenden.

Falls Port 5900 nicht erscheint:

1. `ip -4 -br addr` prüfen (hat der PC noch `192.168.19.174`?).
2. `ls -l /home/cevik/.vnc/passwd` prüfen.
3. `cat /home/cevik/.config/autostart/ticket-display-vnc.desktop` prüfen.
4. Direkt in der **grafischen** Sitzung von `cevik` den Befehl `/usr/local/bin/ticket-display-vnc` starten und Fehlermeldung ablesen; nicht aus reiner SSH-Sitzung ohne DISPLAY starten.

Wenn der Desktop flackert, XFCE-Kompositor testweise deaktivieren. Die VNC-Konfiguration verwendet bereits `-noxdamage`.

## Rückkehr zur verschlüsselten Variante

In `/etc/ticket-display.conf` wieder `VNC_LISTEN_IP="127.0.0.1"` setzen, neu anmelden oder neu starten und **alle direkten UFW-5900-Freigaben entfernen**. Anschließend Windows-SSH-Tunnel:

```powershell
ssh -N -L 5901:127.0.0.1:5900 cevik@192.168.19.174
```

TightVNC Viewer: `127.0.0.1::5901`.
