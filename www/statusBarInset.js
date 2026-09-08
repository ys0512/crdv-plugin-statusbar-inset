var exec = require('cordova/exec');

/**
 * cordova.plugins.statusBarInset.getInsetTopDp(success, error)
 *   success(dp: number) — real status bar inset height in dp, measured via
 *     WindowInsetsCompat (same source cordova-android itself uses to draw the
 *     status bar backdrop), so it matches the visible gray bar exactly on any device.
 *   error(reason: string) — e.g. "insets_not_ready" if called before the window's
 *     first layout pass; caller should retry shortly or fall back to a constant.
 *
 * Android only. No-op on other platforms — callers should feature-detect via
 * `window.cordova && window.cordova.plugins && window.cordova.plugins.statusBarInset`.
 */
module.exports = {
  getInsetTopDp: function (success, error) {
    exec(success, error, 'StatusBarInset', 'getInsetTopDp', []);
  }
};
