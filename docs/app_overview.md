# Offline Currency App — Full Specification (v1)

## 1. Product Overview

The app provides fast offline currency conversions using pre-downloaded exchange rate cards. When online, the app optionally displays a **live chart** for the selected currency pair. Everything is simple, fast, and minimal.

### Core Goals

* Near-instant conversion
* Works without network
* Lightweight UI
* Supports widgets
* Optional online enhancements (chart, updated rates)

---

## 2. Feature List

### 2.1 Essential (MVP)

* Offline currency cards (EUR→THB, USD→THB, etc.)
* Manual input field for amount
* Instant conversion output
* Auto-refresh on input change
* Card management (add/remove)
* Rate update when online
* Local caching of rates
* Home screen widget support

### 2.2 Online-Only Enhancements

* Live chart for each currency pair
* “Updated X minutes ago” indicator
* Pull-to-refresh for latest rate

### 2.3 Premium Features

* Unlimited number of offline cards
* Custom themes
* Historical charts
* Ad-free experience

---

## 3. User Flows

### 3.1 Onboarding

1. User installs app
2. Select main currency (default EUR)
3. Recommended card list appears
4. User adds cards → downloaded & stored

### 3.2 Converting Offline

1. Open app
2. Tap a card
3. Enter amount
4. Conversion instantly updates

### 3.3 Updating Rates (Online)

1. Pull-to-refresh
2. Fetch new rates
3. Store locally
4. Update card timestamp

### 3.4 Premium Upgrade

1. Tap Premium banner
2. Show features
3. One-time purchase or subscription

---

## 4. Technical Specification

### 4.1 Architecture

* Flutter app
* Local storage: Hive or SQLite
* HTTP client: standard
* State management: Riverpod
* Platform channels: for widgets

### 4.2 Data Model

**CurrencyCard**

* id: string
* base: string (e.g. EUR)
* target: string (e.g. THB)
* rate: double
* lastUpdated: DateTime
* historical: List<RatePoint> (premium only)

**RatePoint**

* timestamp: DateTime
* value: double

### 4.3 Storage

* Hive box for cards
* Hive box for preferences

### 4.4 API Endpoints

`GET /rate?base=EUR&target=THB`
Response:

```json
{
  "rate": 37.12,
  "timestamp": "2025-11-24T12:30:00Z"
}
```

`GET /history?base=EUR&target=THB&period=7d`
Response:

```json
{
  "points": [
    { "t": "2025-11-23", "v": 37.10 },
    { "t": "2025-11-24", "v": 37.12 }
  ]
}
```

---

## 5. Database Schema

### Currency Cards Table

| Field        | Type      |
| ------------ | --------- |
| id           | TEXT (PK) |
| base         | TEXT      |
| target       | TEXT      |
| rate         | REAL      |
| last_updated | INT       |
| historical   | BLOB      |

### Preferences Table

| Field | Type |
| ----- | ---- |
| key   | TEXT |
| value | TEXT |

---

## 6. UI Wireframes (Text Version)

### Home Screen

* Header: Selected base currency
* List of cards (vertical)

  * Each card: base → target, current rate, last updated
* Floating + button: Add card
* Premium banner at bottom

### Card Detail Screen

* Title: BASE → TARGET
* Input field: amount
* Output: converted amount (big)
* Section: live chart (only when online)
* Refresh button

### Add Card Screen

* Search currency
* Select target
* Auto-download rate

---

## 7. Premium Plan Definition

### Name: **Offline+ Premium**

* Unlimited offline cards
* Historical charts
* Custom themes
* Remove ads
* Priority rate refresh

Pricing: one-time or subscription (decided later)

---

## 8. Roadmap (Priority)

### P0 — MVP (Offline-first)

* Card system
* Local storage
* Basic UI
* Widgets
* Manual refresh

### P1 — Online extras

* Live chart
* Automatic update

### P2 — Premium

* Themes
* Historical charts
* Remove ads

### P3 — Polishing

* Animations
* Localisation
* Accessibility

---

## 9. Performance Considerations

* Cache chart data info
* Minimize rebuilds
* Card list virtualization
* Keep API payloads tiny
* Use isolates for parsing large data

---

## 10. Future Ideas

* Reverse mode (convert backwards)
* Travel mode (auto-switch base)
* iOS widgets
* Quick actions (long-press)
