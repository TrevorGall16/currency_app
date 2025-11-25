# Offline Currency Cards – UI & UX Wireframes (Based on Mockup)

## 1. Design Principles

* Clean, minimal, practical — mirroring your mockup’s simplicity.
* Fast interactions with almost no delays.
* One-hand usability.
* Layout built around stacked cards + clear top controls.
* Offline-first with optional online features (chart).
* Ads placed in a non-intrusive way.

---

## 2. Global Layout Guidelines

* **Margins:** ~16 px screen edges
* **Card spacing:** ~8–12 px vertically
* **Card padding:** ~12 px internal
* **Tap target minimum:** 44 px
* **Typography:** Large numeric emphasis
* **Colors:** Not defined by mockup → Neutral placeholders

---

## 3. Home Screen (Main Screen)

```
┌─────────────────────────────────────────────┐
│  Home Currency Picker       Refresh Icon    │
│  [ EUR ▼ ]                  ( ↻ )           │
├─────────────────────────────────────────────┤
│  ┌──────────── Card ────────────┐           │
│  │ 100 THB → 2.59 EUR            │           │
│  └───────────────────────────────┘           │
│  ┌──────────── Card ────────────┐           │
│  │ 500 JPY → 3.30 EUR            │           │
│  └───────────────────────────────┘           │
│  ... more cards ...                          │
│                                               │
│               + Add Card                      │
├─────────────────────────────────────────────┤
│                 Banner Ad                     │
└─────────────────────────────────────────────┘
```

### Notes

* Home currency selector is placed at the very top, as in your mockup.
* Refresh icon is on the right for quick manual updates.
* Cards follow your stacked layout.
* Only **one** banner ad at the bottom (from your mockup).
* Card tap → opens detail screen.
* Long press → optional reorder/delete.

---

## 4. Add Card Screen

```
┌────────────────────────────────┐
│ ← Back       Add New Card       │
├────────────────────────────────┤
│ Amount:   [  100   ]            │
│ Currency: [  THB ▼ ]            │
│                                   │
│ Preview: 100 THB → 2.59 EUR       │
│                                   │
│           [   Save Card   ]       │
└────────────────────────────────┘
```

### Notes

* Layout is minimalist, following your mockup’s simplicity.
* Preview updates instantly.

---

## 5. Card Detail Screen

```
┌──────────────────────────────────┐
│ ← Back     100 THB → 2.59 EUR    │
├──────────────────────────────────┤
│ Last updated: 24 Nov 2025        │
│                                  │
│   ─── Chart (online only) ───     │
│  |   mini line chart area       | │
│  |   (7d/30d toggle optional)   | │
│                                  │
│ [Edit Card]     [Delete]          │
└──────────────────────────────────┘
```

### Notes

* If offline → message “Chart unavailable (offline)”.
* Matches your mockup structure with a simple stacked layout.

---

## 6. Settings Screen

```
┌────────────────────────────────┐
│ ← Back        Settings          │
├────────────────────────────────┤
│ Home Currency       [ EUR ▼ ]    │
│ Manual Refresh       [ Button ]   │
│ Auto Sync Rates      [ Toggle ]   │
│ Offline Mode Badge (if needed)    │
│                                   │
│ About / Version Info              │
└────────────────────────────────┘
```

---

## 7. Offline Indicator

* Small tag near top/right.
* Appears when device is offline.
* Hides automatically once reconnected.

Example:

```
[Offline]
```

---

## 8. Widgets

### One-Card Widget

```
┌──────────────────────────────┐
│ 100 THB → 2.59 EUR            │
│ Updated: 3 days ago           │
└──────────────────────────────┘
```

### Three-Card Widget

```
┌──────────────────────────────┐
│ 100 THB → 2.59 EUR            │
│ 200 JPY → 1.45 EUR             │
│ 50 CNY → 6.70 EUR              │
│ Updated: 3 days ago            │
└──────────────────────────────┘
```

---

## 9. Components

* Currency picker (top of home)
* Refresh icon
* Card tile
* Add card button
* Chart area
* Offline badge
* Bottom banner ad
* Edit/delete buttons

---

## 10. Interactions & Behaviors

* Tap card → detail page
* Long press → optional reorder/delete
* Pull-to-refresh → updates rates if online
* New card animates into list
* Offline badge fades in/out

---

This UI spec now fully reflects the structure seen in your mockup image — simple, stacked, and ultra-practical.
