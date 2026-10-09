# Start hier – Ticketanzeige im Team

**Für neue Mitarbeiterinnen und Mitarbeiter · Lesezeit: ca. 2 Minuten**

Willkommen! Im Büro zeigt ein Fernseher die Übersicht unseres bestehenden Ticketsystems. So sieht das Team an einem gemeinsamen Bildschirm, welche Tickets gerade angezeigt werden. **Der Fernseher ist nur eine Anzeige** – Tickets werden weiterhin im eigentlichen Ticketsystem bearbeitet.

> **Kurz gesagt:** Du musst normalerweise nichts starten oder einrichten. Der Tiny-PC öffnet die Ticketansicht automatisch.

## Auf einen Blick

| Frage | Antwort |
|---|---|
| Was läuft hier? | Ein **Tiny-PC mit Debian 13, XFCE und Chromium** zeigt das Ticketsystem auf dem Fernseher. |
| Wann ist die Anzeige vorgesehen? | **Montag bis Freitag, 07:45–17:30 Uhr** (deutsche Ortszeit). Am Wochenende soll der TV aus bzw. im Standby sein. |
| Werden neue Tickets sichtbar? | Die konfigurierte Ticket-Registerkarte soll sich **ungefähr alle 60 Sekunden** aktualisieren. Manche Ticketansichten aktualisieren sich zusätzlich selbst. |
| Wer arbeitet mit den Tickets? | Die Bearbeitung erfolgt weiterhin im **Ticketsystem über den eigenen Arbeitsplatz und die persönliche Berechtigung**. |
| Kann der Bildschirm etwas anderes anzeigen? | Ja, z. B. eine Präsentation oder eine andere Webseite. Danach bitte zur Ticketanzeige zurückkehren. |

**Gut zu wissen:** Der Tiny-PC kann eingeschaltet bleiben, auch wenn der Fernseher außerhalb der Arbeitszeit aus ist. Die TV-Zeitsteuerung ist vom jeweiligen Fernseher und dessen Einstellungen abhängig.

## So verwendest du den Bildschirm

### Ticketübersicht ansehen

- Normalerweise ist das Dashboard beim Einschalten bereits geöffnet.
- Wenn eine Anmeldeseite erscheint, bitte **nicht mit fremden Zugangsdaten anmelden**; wende dich an die zuständige IT-/Ticketadministration.
- Nutze für das Bearbeiten einzelner Tickets deinen eigenen Arbeitsplatz statt des gemeinsam sichtbaren Displays.

### Vorübergehend andere Inhalte zeigen

1. **Alt + Tab** wechselt zu einem anderen geöffneten Fenster.
2. **F11** schaltet den Browser-Vollbildmodus um (bei Fernsteuerung können Sondertasten abweichend ankommen).
3. Im Browser öffnet **Strg + L** die Adresszeile; darüber kannst du eine andere freigegebene Webseite öffnen.
4. Nach deiner Präsentation wieder zur **Ticket-Registerkarte** wechseln. Falls du die Ticketseite in derselben Registerkarte ersetzt hast, die Ticketseite über das vorhandene Lesezeichen bzw. den freigegebenen internen Link aufrufen.

**Bitte beachten:** Der automatische 60-Sekunden-Refresh betrifft nur die konfigurierte Ticket-Registerkarte. Andere geöffnete Webseiten oder Präsentationen werden davon nicht absichtlich neu geladen. Wenn du von der Ticketseite auf eine andere URL wechselst, pausiert der Refresh dort.

### Zurück zum Vollbild

Chromium-Fenster anklicken und **F11** drücken. Falls F11 in einer Fernwartungssitzung nicht wirkt: In Chromium **Menü (⋮) → Zoom → Vollbild-Symbol** verwenden. Nicht versehentlich den gesamten Computer herunterfahren.

## Wenn etwas nicht funktioniert

| Beobachtung | Was du tun kannst |
|---|---|
| Fernseher ist schwarz | Prüfen, ob der Fernseher eingeschaltet ist und der richtige HDMI-Eingang gewählt wurde. Nicht sofort den Tiny-PC ausschalten. |
| „Kein Signal“ | TV-Eingang und Kabel prüfen; wenn unverändert, an IT melden. |
| Browser zeigt eine Anmeldung | An IT bzw. Ticketadministration melden – keine Zugangsdaten weitergeben. |
| Tickets scheinen veraltet | Etwas über eine Minute warten und prüfen, ob sich die Ansicht aktualisiert. Wenn nicht: Störung melden. |
| Präsentation läuft noch | Zur Ticket-Registerkarte bzw. zum Chromium-Fenster zurückwechseln. |
| Es gibt eine Fehlermeldung oder keine Verbindung | Zeit und Fehlermeldung notieren und an die interne IT melden. Keine Systemkonfiguration auf eigene Faust ändern. |

## Datenschutz und Zusammenarbeit

Die Tickets können Namen, Kontaktdaten oder andere betriebliche Informationen enthalten. Deshalb:

- Bildschirm nur dort betreiben, wo die Anzeige **freigegeben** ist.
- Keine Zugangsdaten teilen oder offen sichtbar hinterlassen.
- Keine Ticketfotos oder Screenshots unkontrolliert weitergeben.
- Wartung, Netzwerk, Fernzugriff und Änderungen an der Anzeige gehören zur zuständigen IT.

## Ansprechpartner (intern ergänzen)

Diese Daten bitte **nicht in ein öffentliches GitHub-Repository eintragen**. Die zuständige Stelle kann diese Felder auf einer internen Kopie oder im Team-Wiki ergänzen:

| Thema | Interne Angabe |
|---|---|
| IT-Support / Vertretung | *Intern ergänzen* |
| Ticketsystem-Link / Dashboard | *Intern ergänzen* |
| Standort / Gerätebezeichnung | *Intern ergänzen* |
| Störungsmeldung / Eskalationsweg | *Intern ergänzen* |

---

**Für die IT/Administration:** Technische Einrichtung und Wartung stehen in [INSTALLATION.md](INSTALLATION.md). Hinweise zur 60-Sekunden-Aktualisierung in [AUTO-REFRESH.md](AUTO-REFRESH.md), zum VNC-Fernzugriff in [DIRECT-VNC.md](DIRECT-VNC.md) und zur Systemprüfung in [TESTPLAN.md](TESTPLAN.md).

*Diese Seite beschreibt die vorgesehene Bedienung. Die konkrete TV-Zeitsteuerung und Zugriffsrechte werden am Standort geprüft und verwaltet.*
