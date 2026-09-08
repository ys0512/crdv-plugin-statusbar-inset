# crdv-plugin-android-statusbar-inset

Tiny Cordova plugin (Android only) that returns the real, on-device status bar
inset height in dp, read via `WindowInsetsCompat` — the same API
`cordova-android` itself uses internally (`CordovaActivity#createViews`) to
size the gray status bar backdrop view it draws. Reading it the same way
guarantees the value matches exactly what's on screen, regardless of
device/notch/cutout differences (fixed constants drift badly across devices —
see the timetable_stella project's `docs/` for the incident that motivated this).

## Install

```xml
<plugin name="crdv-plugin-android-statusbar-inset"
  spec="https://github.com/ys0512/crdv-plugin-android-statusbar-inset.git#v1.0.0"/>
```

## Usage

```js
if (window.cordova && window.cordova.plugins && window.cordova.plugins.statusBarInset) {
  window.cordova.plugins.statusBarInset.getInsetTopDp(
    function (dp) { /* real status bar height in dp */ },
    function (reason) { /* e.g. "insets_not_ready" — retry or fall back */ }
  )
}
```

Android only. No iOS/browser implementation — callers should feature-detect
as shown above and fall back to another method (e.g. `screen.height -
innerHeight` works reasonably well on iOS) on other platforms.

## Notes

- Must be called after the window has completed its first layout pass, or it
  returns an `insets_not_ready` error. In practice, calling it from a
  Cordova `deviceready` handler works reliably.
- `androidx.core` (which provides `WindowInsetsCompat`) is not declared as a
  separate dependency here since `cordova-android` itself already pulls it
  in; adding a second copy risks a version conflict.

MIT licensed.
