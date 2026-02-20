# RayGolf

Minimal Handicap + Progress Golf Tracker (Apple Fitness Style)

---

## Goal

Build a clean, fast iOS golf tracking app focused on handicap and progress visualization, inspired by Apple Fitness. No GPS, no social clutter—just a minimalist, motivating dashboard with rings, streaks, and trends to help users see improvement over time.

---

## Core User Story

> “As a golfer, I want to quickly log my round and see my handicap/progress trends in a simple, motivating dashboard so I can tell if I’m improving.”

---

## MVP Features

### 1. Round Logging
- Add a round with:
  - Date (default = today)
  - Course name (free text)
  - Total score for 18 holes (required)
  - Optional: 9-hole/front/back score, notes
- Edit/delete rounds
- Validation: Score must be within a reasonable range (40–200)

### 2. Handicap Estimate (Simple)
- Recent handicap = (average score - 72), using last 10 rounds (or all, if fewer)
- Display as “Estimated Handicap” with info: “Simplified estimate (no slope/rating yet)”
- Model is future-ready for real USGA calculations

### 3. Apple Fitness-style Dashboard
- **Progress Rings (3):**
  - Play: Rounds logged this week vs goal (default 1/week)
  - Consistency: Rounds in last 30 days vs goal (default 4/month)
  - Improve: Fills as recent average beats baseline (see below)
- **Key Metrics Cards:**
  - Estimated Handicap
  - Scoring Average (last 5 rounds)
  - Best Round (last 90 days)
  - Trend Arrow (Improving / Flat / Worsening, based on average last 5 vs previous 5)
- **Trend View:**
  - Simple line chart (X: date, Y: score or handicap; toggle)
- **Streaks:**
  - “Weeks Played in a Row” (≥1 round per week)
  - (Future: Personal Best Streak)

### 4. Goals
- User sets weekly (default 1) and monthly (default 4) round goals
- “Improve” ring logic:
  - Baseline average = first 5 rounds (or all if fewer)
  - If last 5 average < baseline, ring fills:  
    improvementPct = clamp((baselineAvg - last5Avg) / 10, 0...1)

### 5. Data Persistence
- SwiftData (preferred) or Core Data
- Local-only, no accounts or login for MVP

---

## App Structure

- **Platform:** iOS (Swift, SwiftUI, iOS 17+)
- **Tabs:** Dashboard | Rounds | Settings
- **Navigation:** Dashboard cards link to detail screens (Trend, Handicap, etc.)

---

## UI & Design

- Minimal, Apple-like: whitespace, large type, rounded cards, SF Symbols
- Fitness-style rings with smooth animation
- Tasteful gradients or solid ring colors
- Full dark mode support

---

**Codename:** RayGolf

---

## Getting Started

1. Open `RayGolf.xcodeproj` in Xcode.
2. Select a simulator or device (iOS 17+).
3. Build and run (⌘R).

The app stores all data locally with SwiftData. No account or login required.

### Project Structure

```
RayGolf/
├── RayGolfApp.swift      # App entry, SwiftData container
├── ContentView.swift     # Tab navigation
├── Models/
│   └── Round.swift       # SwiftData round model
├── Services/
│   ├── HandicapCalculator.swift
│   ├── StatisticsService.swift
│   └── GoalsStore.swift
├── Views/
│   ├── Dashboard/        # Rings, metrics, trend chart, streaks
│   ├── Rounds/           # List, add, edit rounds
│   └── Settings/         # Goals, about
└── Assets.xcassets
```

---
