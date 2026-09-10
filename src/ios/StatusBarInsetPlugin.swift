import Foundation

/**
 * Exposes the real on-device top safe-area inset (status bar height, in pt) to JS via
 * `window.safeAreaInsets.top` — the same signal admob-plus itself uses internally
 * (AMBCore.swift `AMBHelper.topAnchor` → `window.safeAreaLayoutGuide.topAnchor`) to
 * position banners relative to the status bar. Reading it directly here guarantees the
 * value matches exactly what's on screen, regardless of device/notch/Dynamic Island
 * differences, instead of inferring it from `screen.height - innerHeight` in JS (which
 * proved unreliable: three real launches on the same device produced 62pt, 96pt, and an
 * unmeasurable 0 for the same physical inset).
 *
 * JS side: cordova.plugins.statusBarInset.getInsetTopPt(successCb, errorCb)
 *   successCb(pt: number)
 *   errorCb(reason: string) — e.g. "window_not_ready" if called before the Cordova
 *   view's window exists; callers should retry or fall back to another method.
 */
@objc(StatusBarInsetPlugin)
class StatusBarInsetPlugin: CDVPlugin {

    @objc(getInsetTopPt:)
    func getInsetTopPt(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            guard let window = self.viewController.view.window else {
                let result = CDVPluginResult(status: .error, messageAs: "window_not_ready")
                self.commandDelegate.send(result, callbackId: command.callbackId)
                return
            }
            let topPt = Int32(window.safeAreaInsets.top.rounded())
            let result = CDVPluginResult(status: .ok, messageAs: topPt)
            self.commandDelegate.send(result, callbackId: command.callbackId)
        }
    }
}
