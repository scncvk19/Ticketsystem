/* global chrome, importScripts */
// config.js wird beim Start lokal aus /etc/ticket-display.conf erzeugt.
// Keine Ticket-URL und keine Zugangsdaten im GitHub-Repository speichern.
importScripts("config.js");

const ALARM_NAME = "ticket-display-refresh-60s";
const TARGET_URL = globalThis.ticketDisplayConfig?.targetUrl;
const REFRESH_MINUTES = 1;

function sameTicketPage(url) {
  if (!url || !TARGET_URL) return false;
  try {
    const actual = new URL(url);
    const expected = new URL(TARGET_URL);
    // Hash-Änderungen sind bei Single-Page-Apps erlaubt; andere Pfade
    // oder Query-Parameter können einen anderen Inhalt bedeuten.
    return actual.origin === expected.origin &&
      actual.pathname === expected.pathname &&
      actual.search === expected.search;
  } catch (_) {
    return false;
  }
}

async function findRegisteredTab() {
  const { ticketTabId } = await chrome.storage.local.get("ticketTabId");

  // Ist die ursprüngliche Ticket-Registerkarte nun auf einer anderen Seite,
  // behalten wir die Zuordnung, laden die andere Seite aber NIEMALS neu.
  if (Number.isInteger(ticketTabId)) {
    try {
      return await chrome.tabs.get(ticketTabId);
    } catch (_) {
      await chrome.storage.local.remove("ticketTabId");
    }
  }

  // Einmalig das Ticket-Tab identifizieren; andere Tabs nicht berücksichtigen.
  const tabs = await chrome.tabs.query({});
  const ticket = tabs.find(tab =>
    Number.isInteger(tab.id) && sameTicketPage(tab.url)
  );
  if (ticket) {
    await chrome.storage.local.set({ ticketTabId: ticket.id });
  }
  return ticket ?? null;
}

async function refreshTicket() {
  const tab = await findRegisteredTab();
  if (!tab || !sameTicketPage(tab.url)) return;

  // Reload nur dieser einen Registerkarte – kein Browser-Neustart,
  // keine Aktualisierung fremder Tabs oder anderer Webseiten.
  await chrome.tabs.reload(tab.id, { bypassCache: false });
}

async function ensureAlarm() {
  const existing = await chrome.alarms.get(ALARM_NAME);
  if (!existing) {
    await chrome.alarms.create(ALARM_NAME, {
      delayInMinutes: REFRESH_MINUTES,
      periodInMinutes: REFRESH_MINUTES
    });
  }
}

chrome.alarms.onAlarm.addListener(alarm => {
  if (alarm.name !== ALARM_NAME) return;
  refreshTicket().catch(error => console.error("Ticket refresh:", error));
});

chrome.runtime.onStartup.addListener(() => {
  // Die Browser-Sitzung wurde neu gestartet: Tab-IDs neu erkennen.
  chrome.storage.local.remove("ticketTabId")
    .then(ensureAlarm)
    .catch(error => console.error("Ticket startup:", error));
});

chrome.runtime.onInstalled.addListener(() => {
  chrome.storage.local.remove("ticketTabId")
    .then(ensureAlarm)
    .catch(error => console.error("Ticket install:", error));
});

// Service Worker kann zwischendurch beendet und erneut gestartet werden.
ensureAlarm().catch(error => console.error("Ticket alarm:", error));
