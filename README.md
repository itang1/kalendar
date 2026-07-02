# Kalendar

An iOS app for exploring the Christian liturgical year. Kalendar lays out the
next full year of days, colored by liturgical season and marked with feasts and
solemnities, and explains what each day means. You can browse a whole year at a
glance, read about any day, and keep private notes that persist from year to year.

"Kalendar" is the traditional spelling used in many liturgical texts.

## Features

- **Grid view** of the coming year, one tile per day, always starting with today
  and rolling forward. Tiles are colored by liturgical season or feast so the
  shape of the year stands out at a glance.
- **Wheel view** showing the whole year at once as colored slices.
- **Day detail** with the season, week of the season, vestment color, and, on
  feast days, the feast name and a short explanation of what is being celebrated.
- **Feasts & Solemnities list** for jumping straight to any celebration in the year.
- **Personal notes** on any day, saved automatically. Feast-day notes follow the
  feast even when its date shifts (like Easter); regular-day notes stay on the
  same calendar date each year.
- **Onboarding** that walks through how to read the calendar, plus an in-app
  About screen that can replay it.
- Dark mode and light haptic feedback throughout.

## Liturgical accuracy

Kalendar implements the Roman Rite / General Roman Calendar:

- **Easter** is computed with the Anonymous Gregorian algorithm (Computus), and
  every movable date (Ash Wednesday, the Triduum, Ascension, Pentecost, Trinity
  Sunday, Corpus Christi, Christ the King, the start of Advent, the Baptism of
  the Lord) is derived from it.
- **Seasons** (Advent, Christmas, Ordinary Time, Lent, Triduum, Easter) and their
  vestment colors are assigned per day, including the rose Sundays (Gaudete and
  Laetare).
- **Feast precedence** follows the Table of Liturgical Days: saints' days yield to
  the Triduum, Holy Week, the Octave of Easter, and the Sundays of Advent, Lent,
  and Easter.

Known limitation: an impeded solemnity (such as the Annunciation falling in Holy
Week) is currently omitted for that year rather than transferred to its proper
later date.

## Privacy

Kalendar collects no data and makes no network requests. Notes you add are stored
only on the device, in `UserDefaults`. They do not sync across devices, and
uninstalling the app deletes them.

## Architecture

SwiftUI, targeting iOS 17+. No third-party dependencies.

```
kalendar/
├─ kalendarApp.swift            App entry point
├─ Models/
│  ├─ DayCard.swift             One day of the year
│  ├─ LiturgicalCalendar.swift  Season, feast, and color engine (Computus)
│  └─ KalendarWheel.swift       Wheel view and slice hit-testing
├─ ViewModels/
│  └─ CalendarViewModel.swift   Builds the year and persists notes
├─ Views/
│  ├─ ContentView.swift         Onboarding gate + navigation
│  ├─ CircleCalendarView.swift  Grid/wheel host, info & feast-list sheets
│  ├─ DayCardView.swift         A single grid tile
│  ├─ DayDetailView.swift       Swipeable day detail with notes
│  ├─ OnboardingView.swift      First-launch walkthrough
│  └─ AppIconPreview.swift      DEBUG-only icon generator
└─ Utilities/
   └─ DateHelpers.swift         Date and adaptive-color helpers
```

## Building

Open `kalendar.xcodeproj` in Xcode and run the `kalendar` scheme on an iOS 17+
simulator or device. There are no package or dependency steps.

## Roadmap

Planned work includes accessibility improvements (Dynamic Type, VoiceOver on the
wheel), feast-day notifications, iCloud sync for notes, transferring impeded
solemnities to their proper dates, and a home-screen widget.
