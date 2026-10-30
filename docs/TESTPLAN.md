# Checkliste: Ticketanzeige vor Ort

Die Ticketanzeige auf dem Debian-Tiny-PC läuft nach Rückmeldung aus dem Betrieb. Die folgende Liste dient als Abnahmehilfe bei Änderungen und Neuinstallationen.

**Wichtig:** Nicht jedes einzelne Verhalten ist damit bereits getestet. Die Häkchen erst setzen, wenn der jeweilige Punkt am Gerät geprüft wurde.

## Grundfunktion

- [ ] Debian startet ohne manuelle Anmeldung in XFCE.
- [ ] Chromium öffnet die richtige Ticketseite im Vollbild.
- [ ] Die Ticketanmeldung funktioniert auch nach längerer Laufzeit.
- [ ] Nur die Ticket-Registerkarte lädt ungefähr alle 60 Sekunden neu.
- [ ] Andere Webseiten und Präsentationen bleiben dabei ungestört.
- [ ] Nach einem Neustart erscheint wieder die Ticketanzeige.

## Fernseher

- [ ] Am TV ist der richtige HDMI-Eingang ausgewählt.
- [ ] Die vorgesehene Anzeigezeit 07:45–17:30 Uhr (Mo–Fr) funktioniert.
- [ ] Der Fernseher bleibt während der Dienstzeit eingeschaltet.
- [ ] Außerhalb der Dienstzeit und am Wochenende bleibt er aus bzw. im Standby.
- [ ] Die Zeitsteuerung schaltet wirklich den Fernseher und nicht nur das HDMI-Signal ab.
- [ ] Ein automatischer Einschalttimer springt nicht ungewollt auf TV-Empfang statt HDMI.

## Netzwerk und Fernwartung

- [ ] Der Tiny-PC erreicht den Ticketserver zuverlässig.
- [ ] Bei Netzausfall wird kein scheinbar aktueller Ticketstand angezeigt.
- [ ] Nach Wiederherstellung der Verbindung funktioniert die Ansicht wieder.
- [ ] SSH-Zugriff klappt nur aus den freigegebenen Netzen.
- [ ] VNC verbindet sich mit der laufenden XFCE-Sitzung.
- [ ] VNC-Firewallregeln sind passend zum gewählten Zugriffsweg eingeschränkt.
- [ ] RustDesk ist, falls installiert, separat konfiguriert und geprüft.

## Betrieb

- [ ] Zugriffsrechte des Ticketkontos und Standort des Fernsehers sind freigegeben.
- [ ] Ansprechpartner für Störungen sind intern festgelegt.
- [ ] Updates und Wartung sind einem Verantwortlichen zugeordnet.
- [ ] Ein Ausfall des Tiny-PCs oder des TV führt nicht unbemerkt zum dauerhaften Ausfall der Anzeige.
- [ ] Gerät funktioniert nach geplantem Neustart bzw. Stromausfall wieder wie vorgesehen.

## Notizen bei der Abnahme

| Punkt | Ergebnis / Datum |
| --- | --- |
| Gerät und Standort | Vor Ort eintragen |
| TV-Modell / gewählter HDMI-Eingang | Vor Ort eintragen |
| TV-Steuerung (interner Timer / CEC / manuell) | Vor Ort eintragen |
| Ticketaktualisierung | Vor Ort prüfen |
| Fernwartung | Vor Ort prüfen |
| Zuständige IT-Person | Intern dokumentieren |

**Keine echten Zugangsdaten, vollständigen internen IP-Listen, privaten Schlüssel oder Ticketinhalte in dieses Repository committen.**
