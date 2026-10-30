# Ticketseite alle 60 Sekunden aktualisieren

Die Anzeige verwendet eine kleine Chromium-Erweiterung. Sie lädt die konfigurierte Ticketseite ungefähr einmal pro Minute neu, damit die Übersicht nicht dauerhaft auf einem alten Stand bleibt.

## Was aktualisiert wird

Die Erweiterung sucht eine Registerkarte mit der in `/etc/ticket-display.conf` hinterlegten `TICKET_URL`. Nur diese Registerkarte wird aktualisiert.

Andere Tabs oder Präsentationen bleiben in Ruhe. Sobald man im Ticket-Tab auf eine andere Adresse wechselt, pausiert das Nachladen. Bei Rückkehr zur Ticket-URL geht es weiter.

Die URL muss einschließlich Pfad und Suchparametern passen; der Hash-Teil wird nicht berücksichtigt. Ein Umweg auf eine Anmeldeseite wird nicht automatisch neu geladen.

**Wichtig:** Der Reload ersetzt keine funktionierende Netzwerkverbindung. Auch Anmeldeabläufe und lokale Filter können dadurch zurückgesetzt werden. Für die Anzeige deshalb möglichst ein reines Lesekonto nutzen.

## Nach einem Update prüfen

Ist der Repository-Klon unter `/root/Ticketsystem` vorhanden:

~~~bash
su -
cd /root/Ticketsystem
git pull
bash scripts/install.sh
reboot
~~~

Die Datei `/etc/ticket-display.conf` bleibt erhalten. Die Erweiterung bekommt die Ticket-URL beim Start im lokalen Browserprofil; sie wird nicht mit privaten Zugangsdaten nach GitHub übertragen.

## Funktionstest

1. Chromium startet mit der Ticketseite.
2. Unter `chrome://extensions` wird **Ticket Display – 60s Refresh** als aktiv angezeigt.
3. An der Ticketseite etwa eine Minute lang beobachten, ob sie neu geladen wird. Bei Bedarf im Entwicklerwerkzeug die Netzwerkanfragen prüfen.
4. Eine zweite Webseite in einem anderen Tab öffnen. Sie darf nicht von der Erweiterung neu geladen werden.
5. Im Ticket-Tab vorübergehend auf eine andere URL wechseln. Dort darf kein automatischer Reload erfolgen.
6. Zur Ticketseite zurückgehen. Die Aktualisierung soll wieder einsetzen.
7. Nach einem Neustart den Test wiederholen.

## Wenn der Refresh nicht funktioniert

| Beobachtung | Mögliche Ursache |
| --- | --- |
| Erweiterung fehlt | Installer nicht erneut ausgeführt oder `--load-extension` nicht aktiv |
| Kein Reload | URL stimmt nicht genau, Login-Weiterleitung oder Erweiterung deaktiviert |
| Falscher Tab wird aktualisiert | Mehrere Tabs mit der gleichen Ticketadresse |
| Anderes Fenster wird regelmäßig geschlossen | Veralteter Browser-Neustart aus einer früheren Einrichtung |

Die Erweiterung benutzt Chromium-`tabs`-, `alarms`- und `storage`-APIs. Sie sendet keine eigenen Daten an einen externen Dienst. Die `tabs`-Berechtigung ist relativ weitreichend; deshalb läuft die Erweiterung nur im separaten Ticket-Browserprofil.

Chromium-Richtlinien können lokal geladene Erweiterungen verhindern. Wenn die Erweiterung nicht aktiv ist, kann der 60-Sekunden-Refresh nicht zugesichert werden.
