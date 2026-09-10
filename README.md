# crdv-plugin-statusbar-inset

Tiny Cordova plugin (Android + iOS) that returns the real, on-device status
bar height, read via each platform's own native API — the same references
each platform's own status-bar-handling code already relies on internally.
Reading it the same way guarantees the value matches exactly what's on
screen, regardless of device/notch/Dynamic Island/cutout differences.

Fixed constants and JS-only heuristics (e.g. `screen.height - innerHeight`)
both proved unreliable across devices and cordova-android/cordova-ios
versions — see the timetable_stella project's `docs/` for the incidents
that motivated this (Android: Pixel 7 Pro vs Pixel 11 Pro gave very
different values for the same fixed constant; iOS: the same device gave
62pt, 96pt and an unmeasurable 0 across three real launches).

- Android: `WindowInsetsCompat.getInsets(Type.statusBars()).top` — same
  source `cordova-android`'s own `CordovaActivity#createViews` uses.
- iOS: `UIApplication.shared.statusBarFrame.height` — same source
  `cordova-plugin-statusbar` itself uses (`CDVStatusBar.m`,
  `resizeWebView`/`resizeStatusBarBackgroundView`) to size both its gray
  status bar backdrop view and the WebView's own top offset. Deliberately
  **not** `UIView.safeAreaInsets.top`: on notch/Dynamic Island devices the
  two differ (e.g. iPhone 16: statusBarFrame.height ≈ 54pt vs
  safeAreaInsets.top ≈ 59pt), and using safeAreaInsets left a background-less
  gap between the status bar backdrop and whatever sat right below it —
  scrolled content visibly bled through. Matching cordova-plugin-statusbar's
  own reference value keeps everything aligned on the same line.

## Install

```xml
<plugin name="crdv-plugin-statusbar-inset"
  spec="https://github.com/ys0512/crdv-plugin-statusbar-inset.git#v2.0.2"/>
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
      function (pt) { /* real status bar height in pt */ },
      function (reason) { /* not currently expected to fire on iOS */ }
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
- iOS: `UIApplication.statusBarFrame` was deprecated in iOS 13, but it's the
  same API `cordova-plugin-statusbar` and `admob-plus` (`AMBBanner.swift`)
  both still rely on directly, so it's proven to keep compiling on current
  toolchains.

## History

- v1.0.0: Android only (`crdv-plugin-android-statusbar-inset`).
- v2.0.0: renamed (GitHub repo rename, with automatic redirect from the old
  name) and added iOS support, to keep both platforms' equivalent utility in
  one plugin instead of one repo per platform.
- v2.0.1: fixed a Swift compile error (`messageAsString:`/`messageAsInt:`
  were obsoleted in Swift 3, renamed to `messageAs:`).
- v2.0.2: iOS now reads `statusBarFrame.height` instead of
  `safeAreaInsets.top`, to match `cordova-plugin-statusbar`'s own reference
  value and close a gap that appeared on notch/Dynamic Island devices.

MIT licensed.
