# Kalendar for Android and the web

One Expo / React Native app (the same stack as book-club) that builds the
Android app and the browser calendar at
[itang1.github.io/kalendar/app](https://itang1.github.io/kalendar/app/).
The iPhone app is separate, native SwiftUI, in [`../swift-app/`](../swift-app/).

The liturgical engine is [`src/engine/kalendar-engine.js`](src/engine/kalendar-engine.js),
a port of the Swift engine. `node tools/liturgical-golden.mjs` (from the repo
root) checks it against ten years of expected output; the Swift tests check the
Swift engine against the same file, so the platforms can't drift apart.

## Run it

```bash
npm install
npm start          # dev server; press a for Android, w for web
npm test           # day keys, the year window, countdowns
npm run typecheck
```

## Publish the web version

```bash
npm run build:web  # writes ../docs/app, served by GitHub Pages
```

Commit `docs/app` along with the change. The old `docs/browse.html` redirects
to it.

## Differences from the iPhone app

| | iPhone | Android | Web |
|---|---|---|---|
| Notes | Synced through iCloud | On the device (and in Android's own backup, if on) | None (read-only) |
| Solemnity notifications | Yes | Yes | No |
| Widget | Home Screen + Lock Screen | Not yet | No |
| Introduction | Yes | Yes | No |

Notes use the same keys as the iPhone app (`MM-dd`, or `feast:<id>` for
Easter-cycle feasts), so a note on Easter follows Easter on both.

## Releasing on Google Play

Building the Android app needs either Android Studio on your Mac (for the SDK
and an emulator, then `npm run android`) or EAS Build
(`npx eas build -p android`), which builds in the cloud.
