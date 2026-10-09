"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const workerSource = fs.readFileSync(
  path.join(__dirname, "../extension/background.js"), "utf8"
);

function createBrowser({ ticketUrl, tabs, storedTabId } = {}) {
  const allTabs = tabs || [];
  const reloaded = [];
  const alarms = new Map();
  const events = {};
  const store = Number.isInteger(storedTabId)
    ? { ticketTabId: storedTabId } : {};

  const chrome = {
    storage: {
      local: {
        async get(key) { return { [key]: store[key] }; },
        async set(data) { Object.assign(store, data); },
        async remove(key) { delete store[key]; }
      }
    },
    alarms: {
      async get(name) { return alarms.get(name) || null; },
      async create(name, options) { alarms.set(name, options); },
      onAlarm: { addListener(callback) { events.alarm = callback; } }
    },
    tabs: {
      async get(id) {
        const tab = allTabs.find(t => t.id === id);
        if (!tab) throw new Error("Tab not found");
        return tab;
      },
      async query() { return allTabs.slice(); },
      async reload(id, options) { reloaded.push({ id, options }); }
    },
    runtime: {
      onStartup: { addListener(callback) { events.startup = callback; } },
      onInstalled: { addListener(callback) { events.installed = callback; } }
    }
  };
  const context = {
    chrome, URL,
    console,
    importScripts(file) {
      assert.equal(file, "config.js");
      context.ticketDisplayConfig = {
        targetUrl: ticketUrl || "https://tickets.example.test/board?view=all"
      };
    }
  };
  context.globalThis = context;
  vm.createContext(context);
  vm.runInContext(workerSource, context, { filename: "background.js" });

  return {
    reloaded,
    store,
    tabs: allTabs,
    alarms,
    async tick(name = "ticket-display-refresh-60s") {
      await events.alarm({ name });
    },
    onStartup() { events.startup(); }
  };
}

const URL_TICKET = "https://tickets.example.test/board?view=all";

test("erkennt Ticketseite und aktualisiert nur das Ticket-Tab", async () => {
  const browser = createBrowser({
    tabs: [
      { id: 7, url: URL_TICKET },
      { id: 9, url: "https://example.org/presentation" }
    ]
  });
  await browser.tick();
  await browser.tick();
  assert.deepEqual(browser.reloaded.map(item => item.id), [7, 7]);
  assert.equal(browser.store.ticketTabId, 7);
});

test("andere Tabs und fremde Alarme bleiben unangetastet", async () => {
  const browser = createBrowser({
    tabs: [
      { id: 10, url: URL_TICKET },
      { id: 11, url: "https://example.org/important-form" }
    ]
  });
  await browser.tick("unrelated-alarm");
  assert.equal(browser.reloaded.length, 0);
  await browser.tick();
  assert.deepEqual(browser.reloaded.map(item => item.id), [10]);
});

test("bei Navigation des Ticket-Tabs auf andere Seite wird kein Reload ausgelöst", async () => {
  const browser = createBrowser({
    tabs: [
      { id: 20, url: URL_TICKET },
      { id: 21, url: "https://example.org" }
    ]
  });
  await browser.tick();
  browser.tabs[0].url = "https://example.org/notes";
  await browser.tick();
  assert.deepEqual(browser.reloaded.map(item => item.id), [20]);
  // Gleichnamiger Tab an anderer Stelle darf nicht versehentlich übernommen werden.
  browser.tabs[1].url = URL_TICKET;
  await browser.tick();
  assert.deepEqual(browser.reloaded.map(item => item.id), [20]);
  // Erst wenn die ursprüngliche Ticket-Registerkarte zurückkehrt, wird sie aktualisiert.
  browser.tabs[0].url = URL_TICKET;
  await browser.tick();
  assert.deepEqual(browser.reloaded.map(item => item.id), [20, 20]);
});

test("andere Pfade und Query-Parameter werden nicht aktualisiert", async () => {
  const browser = createBrowser({
    tabs: [
      { id: 30, url: "https://tickets.example.test/login" },
      { id: 31, url: "https://tickets.example.test/board?view=private" }
    ]
  });
  await browser.tick();
  assert.equal(browser.reloaded.length, 0);
  browser.tabs.push({ id: 32, url: URL_TICKET + "#section" });
  await browser.tick();
  assert.deepEqual(browser.reloaded.map(item => item.id), [32]);
});

test("geschlossene Ticket-Registerkarte kann neu gebunden werden", async () => {
  const browser = createBrowser({
    storedTabId: 999,
    tabs: [{ id: 41, url: URL_TICKET }]
  });
  await browser.tick();
  assert.deepEqual(browser.reloaded.map(item => item.id), [41]);
  assert.equal(browser.store.ticketTabId, 41);
});

test("eine 60-Sekunden-Wiederholung wird eingerichtet", async () => {
  const browser = createBrowser({ tabs: [] });
  // Alarmregistrierung erfolgt asynchron bei Service-Worker-Initialisierung.
  await new Promise(resolve => setImmediate(resolve));
  assert.equal(
    browser.alarms.get("ticket-display-refresh-60s").periodInMinutes,
    1
  );
});
