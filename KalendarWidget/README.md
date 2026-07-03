# Kalendar Widget

A Home Screen widget showing today's liturgical season, color, and feast (the
"Today in the Church Year" widget). Small and medium sizes.

## Why LiturgicalCalendar.swift is duplicated here

This target has its own copy of the liturgical engine
([`LiturgicalCalendar.swift`](LiturgicalCalendar.swift)) instead of sharing
`kalendar/Models/LiturgicalCalendar.swift` from the app target. The app's
`Models/` folder is a synchronized group owned by the `kalendar` target;
extending that group's membership to this target as well requires editing
`project.pbxproj`'s target-membership exception sets by hand, which risks
getting the project file into a state Xcode can't open. Duplicating one
self-contained file was the lower-risk trade.

**If the app's liturgical engine changes, update this copy to match.**

## Building

Select the `KalendarWidgetExtension` scheme and build, or just build/run the
`kalendar` app and long-press the Home Screen to add the widget.
