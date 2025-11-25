\# Offline Currency Cards – UI \& UX Wireframes Document



\## 1. Design Principles



\* Minimalist and ultra-fast

\* One-hand usability

\* Large touch targets

\* Zero-wait interactions

\* Offline-first with subtle online enhancements (charts)

\* Ads placed without harming ergonomics



---



\## 2. Color \& Typography Guidelines



\*\*Primary color:\*\* Deep blue-gray



\*\*Accent color:\*\* Bright cyan (for conversion highlights)

\# Offline Currency Cards – UI \& UX Wireframes Document



\## 1. Design Principles



\* Minimalist and ultra-fast

\* One-hand usability

\* Large touch targets

\* Zero-wait interactions

\* Offline-first with subtle online enhancements (charts)

\* Ads placed without harming ergonomics



---



\## 2. Color \& Typography Guidelines



\*\*Primary color:\*\* Deep blue-gray



\*\*Accent color:\*\* Bright cyan (for conversion highlights)



\*\*Typography:\*\*



\* Title: 20–22 px, semi-bold

\* Section labels: 14–16 px

\* Numbers: 24–30 px, mono-spaced for stability



\*\*Spacing:\*\*



\* Minimum 12 px padding

\* 16–20 px between major sections



---



\## 3. Screen-by-Screen Wireframes



\### \*\*A. Home Screen (Main Overview)\*\*



```

┌────────────────────────────────┐

│ \[Home Currency Selector ▼]     │

├────────────────────────────────┤

│   CARD LIST                    │

│  ┌──────────────────────────┐  │

│  │ 100 THB → 2.59 EUR       │  │

│  │  \[precision note]        │  │

│  └──────────────────────────┘  │

│  ┌──────────────────────────┐  │

│  │  200 THB → 5.18 EUR      │  │

│  │  \[updated x days ago]    │  │

│  └──────────────────────────┘  │

│                                │

│ + Add Card Button              │

├────────────────────────────────┤

│ Inline Ad 1 (Top Banner)       │

│ Inline Ad 2 (Bottom Banner)    │

└────────────────────────────────┘

```



\*\*Notes:\*\*



\* Tap on a card → open detail screen

\* Long press → reorder or delete card

\* Pull-to-refresh when online



---



\### \*\*B. Add Card Screen\*\*



```

┌────────────────────────────────┐

│  \[Back]   Add Card             │

├────────────────────────────────┤

│  Amount Input: \[   100   ]     │

│  Currency Picker: \[ THB ▼ ]    │

│                                │

│  Preview: 100 THB → 2.59 EUR   │

│                                │

│         \[ Add Card ]           │

└────────────────────────────────┘

```



\*\*UX Notes:\*\*



\* Amount input uses large number pad

\* Live updated preview



---



\### \*\*C. Card Detail Screen\*\*



```

┌────────────────────────────────┐

│ \[Back]   100 THB               │

├────────────────────────────────┤

│  100 THB = 2.59 EUR            │

│  Updated: 3 days ago           │

│                                │

│  ── CHART (when online) ──     │

│  |        small chart        | │

│  |   7d / 30d toggle         | │

│                                │

│  \[Edit Card]   \[Delete]        │

└────────────────────────────────┘

```



\*\*Notes:\*\*



\* Chart loads only if online

\* Otherwise display: "No internet. Chart unavailable."



---



\### \*\*D. Settings Screen\*\*



```

┌────────────────────────────────┐

│ \[Back] Settings                │

├────────────────────────────────┤

│  Home Currency     \[ EUR ▼ ]   │

│  Refresh Rates     \[ Manual ]  │

│  Auto-sync         \[ Toggle ]  │

│                                │

│  About / Privacy                │

│  Rate the App                  │

└────────────────────────────────┘

```



---



\### \*\*E. Offline Mode Indicator\*\*



```

\[Offline] gray tag near top right

```



---



\## 4. Widget Wireframes



\### \*\*Widget: 1-card layout\*\*



```

┌──────────────────────────────┐

│ 100 THB → 2.59 EUR           │

│ Updated 3d ago               │

└──────────────────────────────┘

```



\### \*\*Widget: 3-card layout\*\*



```

┌──────────────────────────────┐

│ 100 THB → 2.59 EUR           │

│ 200 THB → 5.18 EUR           │

│ 500 JPY → 3.05 EUR           │

│ Updated: 3d ago              │

└──────────────────────────────┘

```



\*\*Widget Interaction:\*\*



\* Tap → opens app Home

\* Force refresh when online



---



\## 5. Ad Placement Overview



\* \*\*Main Screen:\*\* 2 inline banners stacked

\* \*\*Settings / Add Card / Detail:\*\* No ads

\* \*\*Widget:\*\* No ads



Ads never interrupt the card list.



---



\## 6. Micro-Interactions



\* Smooth fade when rates refresh

\* Haptic tick when adding a card

\* Pull-to-refresh bounce

\* Offline badge animates in/out



---



\## 7. Component Inventory



\* Currency Picker

\* Card Tile

\* Chart Tile

\* Add Button

\* Inline Ads

\* Widgets (1-card, 3-card)

\* Offline Badge



---



If you'd like, I can produce a separate high-fidelity mockup style (color blocks, layout spacing, etc.).



\*\*Typography:\*\*



\* Title: 20–22 px, semi-bold

\* Section labels: 14–16 px

\* Numbers: 24–30 px, mono-spaced for stability



\*\*Spacing:\*\*



\* Minimum 12 px padding

\* 16–20 px between major sections



---



\## 3. Screen-by-Screen Wireframes



\### \*\*A. Home Screen (Main Overview)\*\*



```

┌────────────────────────────────┐

│ \[Home Currency Selector ▼]     │

├────────────────────────────────┤

│   CARD LIST                    │

│  ┌──────────────────────────┐  │

│  │ 100 THB → 2.59 EUR       │  │

│  │  \[precision note]        │  │

│  └──────────────────────────┘  │

│  ┌──────────────────────────┐  │

│  │  200 THB → 5.18 EUR      │  │

│  │  \[updated x days ago]    │  │

│  └──────────────────────────┘  │

│                                │

│ + Add Card Button              │

├────────────────────────────────┤

│ Inline Ad 1 (Top Banner)       │

│ Inline Ad 2 (Bottom Banner)    │

└────────────────────────────────┘

```



\*\*Notes:\*\*



\* Tap on a card → open detail screen

\* Long press → reorder or delete card

\* Pull-to-refresh when online



---



\### \*\*B. Add Card Screen\*\*



```

┌────────────────────────────────┐

│  \[Back]   Add Card             │

├────────────────────────────────┤

│  Amount Input: \[   100   ]     │

│  Currency Picker: \[ THB ▼ ]    │

│                                │

│  Preview: 100 THB → 2.59 EUR   │

│                                │

│         \[ Add Card ]           │

└────────────────────────────────┘

```



\*\*UX Notes:\*\*



\* Amount input uses large number pad

\* Live updated preview



---



\### \*\*C. Card Detail Screen\*\*



```

┌────────────────────────────────┐

│ \[Back]   100 THB               │

├────────────────────────────────┤

│  100 THB = 2.59 EUR            │

│  Updated: 3 days ago           │

│                                │

│  ── CHART (when online) ──     │

│  |        small chart        | │

│  |   7d / 30d toggle         | │

│                                │

│  \[Edit Card]   \[Delete]        │

└────────────────────────────────┘

```



\*\*Notes:\*\*



\* Chart loads only if online

\* Otherwise display: "No internet. Chart unavailable."



---



\### \*\*D. Settings Screen\*\*



```

┌────────────────────────────────┐

│ \[Back] Settings                │

├────────────────────────────────┤

│  Home Currency     \[ EUR ▼ ]   │

│  Refresh Rates     \[ Manual ]  │

│  Auto-sync         \[ Toggle ]  │

│                                │

│  About / Privacy                │

│  Rate the App                  │

└────────────────────────────────┘

```



---



\### \*\*E. Offline Mode Indicator\*\*



```

\[Offline] gray tag near top right

```



---



\## 4. Widget Wireframes



\### \*\*Widget: 1-card layout\*\*



```

┌──────────────────────────────┐

│ 100 THB → 2.59 EUR           │

│ Updated 3d ago               │

└──────────────────────────────┘

```



\### \*\*Widget: 3-card layout\*\*



```

┌──────────────────────────────┐

│ 100 THB → 2.59 EUR           │

│ 200 THB → 5.18 EUR           │

│ 500 JPY → 3.05 EUR           │

│ Updated: 3d ago              │

└──────────────────────────────┘

```



\*\*Widget Interaction:\*\*



\* Tap → opens app Home

\* Force refresh when online



---



\## 5. Ad Placement Overview



\* \*\*Main Screen:\*\* 2 inline banners stacked

\* \*\*Settings / Add Card / Detail:\*\* No ads

\* \*\*Widget:\*\* No ads



Ads never interrupt the card list.



---



\## 6. Micro-Interactions



\* Smooth fade when rates refresh

\* Haptic tick when adding a card

\* Pull-to-refresh bounce

\* Offline badge animates in/out



---



\## 7. Component Inventory



\* Currency Picker

\* Card Tile

\* Chart Tile

\* Add Button

\* Inline Ads

\* Widgets (1-card, 3-card)

\* Offline Badge



---



If you'd like, I can produce a separate high-fidelity mockup style (color blocks, layout spacing, etc.).



