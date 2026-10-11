# Kalendar

**A visual calendar of the church year, built through a Reformed lens.** Kalendar lays the year out as a **continuous ring of seasons** so you can see the shape of the year instead of just counting days forward.

Available as an **iOS app**, an **Android app** (coming soon), or in your browser at [itang1.github.io/kalendar](https://itang1.github.io/kalendar/)

[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/app/idXXXXXXXXX)

## Built Through a Reformed Lens

Unlike the historical liturgical calendar, which is Catholic in origin, Kalendar filters it through a **Reformed** view, keeping the central seasons while omitting saints' days.

- **Kept:** the core (Advent, Christmas, Epiphany, Lent, Good Friday, Easter, Ascension, Pentecost, Trinity), plus days remembering people and events (the apostles, the Gospel writers, John the Baptist).
- **Removed:** saints' days and devotions, such as Corpus Christi, the Sacred Heart, Divine Mercy, All Souls, and the Marian feasts.
- **Added:** **Reformation Day** (Oct 31) and a layer of everyday **U.S. holidays**.

['Kalendar'](https://en.wikipedia.org/wiki/Liturgical_year) is the traditional spelling of the liturgical year.

## Features

- **See the whole year:** grid and wheel views, each day colored by its liturgical season.
- **Tap any day:** its season, feast, and today's color, with a note when the color breaks from the season.
- **U.S. holidays:** federal and common cultural days shown *alongside* the church calendar, marked with a small corner diamond.
- **Private notes:** kept per day, synced across your devices through iCloud on iPhone and iPad, kept on the device on Android, never sent to a third party.
- **Extras:** Home Screen and Lock Screen widgets, optional solemnity notifications, and full dark mode.

## Tech stack

- **iOS:** SwiftUI, iOS 17+, zero third-party dependencies.
- **Android and web:** one Expo / React Native app in [`expo-app/`](expo-app/), the same stack as book-club. Its web build is the browser calendar in `docs/app/`.
- The liturgical engine exists in Swift and in JavaScript (shared by Android and web), guarded by a golden-decade drift test (`node tools/liturgical-golden.mjs`).

## Setup

**iOS prerequisites:** Xcode 16+ and an iOS 17+ simulator or device.

```bash
git clone https://github.com/itang1/kalendar.git
cd kalendar
open swift-app/kalendar.xcodeproj
```

**Android and web:** see [`expo-app/README.md`](expo-app/README.md).

## License

> **Source-available, not open-source.** This repository is published for viewing only. Per the [LICENSE](LICENSE), no permission is granted to copy, modify, redistribute, or run this code without the author's written permission.
