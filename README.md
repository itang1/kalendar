# Kalendar

**A visual calendar of the church year, built through a Reformed lens.** Kalendar lays the year out as a **continuous ring of seasons** so you can see the shape of the year instead of just counting days forward.

Available as an **iOS app** or website preview at [itang1.github.io/kalendar](https://itang1.github.io/kalendar/)

[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/app/idXXXXXXXXX)

## Built Through a Reformed Lens

Unlike the historical liturgical calendar, which is Catholic in origin, Kalendar filters it through a **Reformed** view, stripping away hundreds of saint days to leave a historically grounded calendar.

- **Kept:** the core (Advent, Christmas, Epiphany, Lent, Good Friday, Easter, Ascension, Pentecost, Trinity), plus days remembering people and events (the apostles, the Gospel writers, John the Baptist).
- **Removed:** saints' days and devotions, such as Corpus Christi, the Sacred Heart, Divine Mercy, All Souls, and the Marian feasts.
- **Added:** **Reformation Day** (Oct 31) and a layer of everyday **U.S. holidays**.

## Features

- **See the whole year:** grid and wheel views, each day colored by its liturgical season.
- **Tap any day:** its season, feast, and today's color, with a note when the color breaks from the season.
- **U.S. holidays:** federal and common cultural days shown *alongside* the church calendar, marked with a small corner diamond.
- **Private notes:** kept per day, synced across your devices through iCloud, never sent to a third party.
- **Extras:** Home Screen widget, optional solemnity notifications, and full dark mode.

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

## License

> **Source-available, not open-source.** This repository is published for viewing only. Per the [LICENSE](LICENSE), no permission is granted to copy, modify, redistribute, or run this code without the author's written permission.
