# Kalendar Widget (draft, not yet integrated)

This folder has ready-to-use source for a "Today" home screen widget, but it is
**not part of the Xcode project yet**. Creating a new build target (a Widget
Extension) means adding a `PBXNativeTarget`, its own Info.plist/entitlements, and
an "Embed App Extensions" build phase to the app target. Xcode's target-creation
wizard generates all of that correctly in one step; hand-editing `project.pbxproj`
to fabricate a second target is exactly the kind of change that's easy to get
subtly wrong and hard to verify without Xcode itself, so it was left for you to
create through the GUI rather than risk corrupting the one project file the whole
app depends on.

## Steps to add it

1. In Xcode: **File → New → Target… → Widget Extension**. Name it `KalendarWidget`.
   Uncheck "Include Configuration Intent" (this widget isn't user-configurable).
2. Delete the placeholder Swift file Xcode generates for the new target and add
   [`KalendarWidget.swift`](KalendarWidget.swift) from this folder to the new
   target instead.
3. Select `kalendar/Models/LiturgicalCalendar.swift` and
   `kalendar/Models/DayCard.swift` in the project navigator, open the File
   Inspector, and check the new `KalendarWidget` target under **Target
   Membership** (alongside the existing `kalendar` app target). The widget reuses
   the same liturgical engine directly, no data sharing or App Group required,
   since it only needs today's date.
4. Build the `KalendarWidget` scheme, then build/run `kalendar` and long-press the
   Home Screen to add the widget.

## What it shows

Today's liturgical color as the background, and the feast name (or season name if
there's no feast) in the foreground. Supports the small and medium widget sizes.
