# Kalendar

<!-- Once the app is live, replace idXXXXXXXXX with the App Store app ID. -->
[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/app/idXXXXXXXXX)

**Kalendar** is an iOS app for exploring the liturgical year. It lays out the year ahead as a grid of days, each colored by its season and marked with the feasts that fall on it, with a plain-language explanation of what every day means and how the calendar fits together.

**Website:** [itang1.github.io/kalendar](https://itang1.github.io/kalendar/), with a [browsable web demo](https://itang1.github.io/kalendar/browse.html) for anyone without an iPhone.

> "Kalendar" is the traditional spelling used in many liturgical texts.

## Features

### See the whole year at a glance
- **Grid view:** one tile per day, always starting with today and rolling forward.
- **Wheel view:** the entire year as colored slices.
- Tiles are colored by season and feast, so the shape of the year stands out instantly.

### Understand any day
- Season, week of the season, and **vestment color**, each with a short explanation.
- On feasts: the name, a concise write-up, and a **Share** button.
- A link to the day's **readings**, plus the relevant reading cycles.

### An accurate calendar engine
- Implements the full **Roman Rite / General Roman Calendar**.
- Computes **Easter** with the Computus algorithm and derives every movable feast from it.
- Handles **seasons, rose Sundays, feast precedence, and transferred solemnities** correctly.

### Private notes, synced
- Keep **personal notes** on any day, saved automatically and synced across your devices through **iCloud**.
- Feast notes follow the feast when its date moves (like Easter); everything stays private to your Apple ID and is never sent to a third party.

### Thoughtful extras
- **Home Screen widget** showing today's season, feast, and color.
- Optional **morning notifications** on solemnities like Easter and Christmas.
- Guided onboarding, full **dark mode**, and haptic feedback throughout.

## Quick Start

**Prerequisites:** Xcode 16 or later and an iOS 17+ simulator or device. There are no third-party dependencies to install.

1. **Clone** the repository:
   ```bash
   git clone https://github.com/itang1/kalendar.git
   cd kalendar
   ```
2. **Open** the project in Xcode:
   ```bash
   open kalendar.xcodeproj
   ```
3. **Select** the `kalendar` scheme with any iOS 17+ simulator.
4. **Run** with `Cmd + R`. Run the test suite anytime with `Cmd + U`.

**No Xcode?** Try the [browsable web demo](https://itang1.github.io/kalendar/browse.html) in any browser, or open `docs/browse.html` locally.

## Project Layout

The app follows a standard SwiftUI **MVVM** layout (`Models`, `Views`, `ViewModels`, `Services`). The liturgical engine is duplicated across the app, the Home Screen widget, and the web demo; a test suite guards the copies against drift.

## Built With

**SwiftUI**, targeting **iOS 17+**, with zero third-party dependencies. The liturgical logic lives in a single pure-Swift engine, mirrored to JavaScript for the web demo and guarded by tests against drift.
