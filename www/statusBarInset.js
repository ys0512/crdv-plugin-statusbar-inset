var exec = require('cordova/exec');

/**
 * cordova.plugins.statusBarInset — real status bar / top-safe-area inset, read from
 * native APIs so it always matches what's actually drawn on screen (no fixed constants,
 * no fragile JS-only heuristics). Call the method matching the current platform.
 *
 * Android: getInsetTopDp(success, error)
 *   success(dp: number) — via WindowInsetsCompat (same source cordova-android itself
 *     uses to draw its status bar backdrop view).
 *   error(reason: string) — e.g. "insets_not_ready" if called before the window's first
 *     layout pass; caller should retry shortly or fall back.
 *
 * iOS: getInsetTopPt(success, error)
 *   success(pt: number) — via UIView.safeAreaInsets.top (same source admob-plus itself
 *     uses internally to position banners relative to the status bar).
 *   error(reason: string) — e.g. "window_not_ready".
 *
 * Neither method exists on the other platform — feature-detect before calling:
 *   window.cordova && window.cordova.plugins && window.cordova.plugins.statusBarInset
 */
module.exports = {
  getInsetTopDp: function (success, error) {
    exec(success, error, 'StatusBarInset', 'getInsetTopDp', []);
  },
  getInsetTopPt: function (success, error) {
    exec(success, error, 'StatusBarInset', 'getInsetTopPt', []);
  }
};
