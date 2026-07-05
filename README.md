# Kalendar

**A calendar of the church year, read through a Reformed lens.** Kalendar lays the year out as a ring of seasons — from Advent through Easter and the long green stretch of Ordinary Time — so you can see the shape of the year, not just count days forward.

<!-- Once the app is live, replace idXXXXXXXXX with the App Store app ID. -->
[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/app/idXXXXXXXXX)

**Website:** [itang1.github.io/kalendar](https://itang1.github.io/kalendar/) · **No iPhone?** Try the [web demo](https://itang1.github.io/kalendar/browse.html).

## The Reformed lens

The historic liturgical calendar is Catholic in origin. Kalendar filters it through a **Reformed** view of worship — Scripture as the final authority, and only what the Reformed tradition actually observes:

- **Kept** — the Christological core: **Advent, Christmas, Epiphany, Lent, Good Friday, Easter, Ascension, Pentecost, Trinity** — plus days remembering people and events from Scripture (the apostles, the Gospel writers, John the Baptist).
- **Removed** — non-biblical saints' days and devotions without footing in Scripture: Corpus Christi, the Sacred Heart, Divine Mercy, All Souls, and the Marian feasts.
- **Added** — **Reformation Day** (Oct 31) and a layer of everyday **U.S. holidays**.

Names and descriptions use a plain, describing voice — "Catholic churches use violet," not "the priest wears violet" — so nothing in the app needs a specialist to explain.

## Features

- **See the whole year** — grid and wheel views, each day colored by its liturgical season.
- **Tap any day** — its season, feast, and today's color, with a note when the color breaks from the season.
- **U.S. holidays** — federal and common cultural days shown *alongside* the church calendar, marked with a small corner diamond so they never blur into the liturgical days.
- **Private notes** — kept per day, synced across your devices through iCloud, never sent to a third party.
- **Extras** — Home Screen widget, optional solemnity notifications, and full dark mode.

## Tech stack

- **SwiftUI**, iOS 17+, zero third-party dependencies.
- A pure-Swift liturgical engine, mirrored to JavaScript for the web demo and guarded by a golden-decade drift test.

## Setup

**Prerequisites:** Xcode 16+ and an iOS 17+ simulator or device.

```bash
git clone https://github.com/itang1/kalendar.git
cd kalendar
open kalendar.xcodeproj
```

Run the `kalendar` scheme with `⌘R`; run the tests with `⌘U`. No Xcode? Open `docs/browse.html` in any browser.

## License

> **Source-available, not open-source.** This repository is published for viewing only. Per the [LICENSE](LICENSE), no permission is granted to copy, modify, redistribute, or run this code without the author's written permission.
