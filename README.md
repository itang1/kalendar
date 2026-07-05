# Kalendar

<!-- Once the app is live, replace idXXXXXXXXX with the App Store app ID. -->
[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/app/idXXXXXXXXX)

**Kalendar** is an iOS app for exploring the liturgical year. It lays out the year ahead as a grid of days, each colored by its season and marked with the feasts that fall on it, with a plain-language explanation of what every day means and how the calendar fits together.

**Website:** [itang1.github.io/kalendar](https://itang1.github.io/kalendar/), with a [browsable web demo](https://itang1.github.io/kalendar/browse.html) for anyone without an iPhone.

"Kalendar" is the traditional spelling used in many liturgical texts.

## The idea

Time isn't only a line. It's also a wheel. The same seasons come back around every year, the same day of rest comes back around every week, and we live inside those returns whether we notice them or not. A calendar that only counts forward — day 1, day 2, day 3 — misses the shape of it. Kalendar is built to show the shape: the year as a ring of seasons, each with its own color and its own weather of the soul, turning from waiting to celebration to the long ordinary middle and back to waiting again.

That rhythm is old. Advent leans forward in the dark; Christmas holds still in the light; Lent strips things down; Easter runs a full fifty days, because some joys are too big for one day. Ordinary Time — the long green stretch — is where most of a life actually happens. Laying the year out this way is, honestly, how I see the world: cyclical, seasonal, patterned, made of small routines that repeat until they start to mean something.

### A Reformed reading

This is a **Reformed** view of the church year, not a Catholic one. "Reformed" is the Protestant stream that traces back to the Reformation of the 1500s and teachers like John Calvin: Scripture as the final authority, salvation as a gift received by faith, and worship kept simple. The historic calendar Kalendar draws on is Catholic in origin, so I've kept the parts the whole church shares and set aside the parts my tradition doesn't hold.

- **Kept** — the seasons that follow the life of Jesus (Advent through Pentecost), and the days that remember people and events from Scripture: the apostles, the Gospel writers, John the Baptist, and the events of Jesus' own life.
- **Set aside** — the veneration of saints, and devotions without clear footing in Scripture, such as Corpus Christi, the Sacred Heart, Divine Mercy, and All Souls. Where the app describes a practice, it names who keeps it rather than telling you to.
- **Added** — Reformation Day (October 31), the anniversary that gave the Protestant and Reformed traditions their name, and a layer of everyday **U.S. holidays** (federal days plus common cultural ones) so the church year sits inside the year you actually live. Civil days are marked with a small corner diamond, kept visually and structurally separate from the liturgical seasons — they never change a day's color or count as a feast.

Where the app still describes a practice or a color, it uses plain words and a describing voice — "Catholic churches use violet," not "the priest wears violet" — so nothing in it needs a specialist to explain.

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
- Computes the church year from scratch: **Easter** via the Computus algorithm, with every movable feast derived from it.
- Handles **seasons, rose Sundays, feast precedence, and transferred solemnities** correctly.
- Curated for a **Reformed reader** — see [The idea](#the-idea) for what that means.

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
