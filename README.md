# crdv-plugin-statusbar-inset

Tiny Cordova plugin (Android + iOS) that returns the real, on-device status
bar / top-safe-area inset height, read via each platform's own native API —
the same APIs the platform (or admob-plus) itself uses internally to draw
the status bar backdrop / position banners. Reading it the same way
guarantees the value matches exactly what's on screen, regardless of
device/notch/Dynamic Island/cutout differences.

Fixed constants and JS-only heuristics (e.g. `screen.height - innerHeight`)
both proved unreliable across devices and cordova-android/cordova-ios
versions — see the timetable_stella project's `docs/` for the incidents
that motivated this (Android: Pixel 7 Pro vs Pixel 11 Pro gave very
different values for the same fixed constant; iOS: the same device gave
62pt, 96pt and an unmeasurable 0 across three real launches).

- Android: `WindowInsetsCompat.getInsets(Type.statusBars()).top` — same
  source `cordova-android`'s own `CordovaActivity#createViews` uses.
- iOS: `UIView.safeAreaInsets.top` — same source `admob-plus`'s own
  `AMBCore.swift` (`AMBHelper.topAnchor` → `window.safeAreaLayoutGuide`)
  uses.

## Install

```xml
<plugin name="crdv-plugin-statusbar-inset"
  spec="https://github.com/ys0512/crdv-plugin-statusbar-inset.git#v2.0.0"/>
```

## Usage

```js
if (window.cordova && window.cordova.plugins && window.cordova.plugins.statusBarInset) {
  if (window.cordova.platformId === 'android') {
    window.cordova.plugins.statusBarInset.getInsetTopDp(
      function (dp) { /* real status bar height in dp */ },
      function (reason) { /* e.g. "insets_not_ready" — retry or fall back */ }
    )
  } else if (window.cordova.platformId === 'ios') {
    window.cordova.plugins.statusBarInset.getInsetTopPt(
      function (pt) { /* real status bar / safe-area-top height in pt */ },
      function (reason) { /* e.g. "window_not_ready" — retry or fall back */ }
    )
  }
}
```

Each platform only implements its own method — always feature-detect and
branch on `window.cordova.platformId` as shown above, and keep a fallback
(fixed constant or another heuristic) for the rare case the call errors out.

## Notes

- Android: must be called after the window has completed its first layout
  pass, or it returns an `insets_not_ready` error. Calling it from a Cordova
  `deviceready` handler works reliably in practice.
- `androidx.core` (which provides `WindowInsetsCompat`) is not declared as a
  separate dependency since `cordova-android` itself already pulls it in;
  adding a second copy risks a version conflict.
- iOS: requires the Cordova view to already have a `window` (again, calling
  from `deviceready` works reliably in practice); otherwise returns
  `window_not_ready`.

## History

- v1.0.0: Android only (`crdv-plugin-android-statusbar-inset`).
- v2.0.0: renamed (GitHub repo rename, with automatic redirect from the old
  name) and added iOS support, to keep both platforms' equivalent utility in
  one plugin instead of one repo per platform.

MIT licensed.
