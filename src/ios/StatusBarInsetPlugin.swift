import Foundation

/**
 * Exposes the real on-device status bar height (in pt) to JS via
 * `UIApplication.shared.statusBarFrame.height` — deliberately NOT
 * `window.safeAreaInsets.top`. On notch / Dynamic Island devices these two values
 * differ (e.g. iPhone 16: statusBarFrame.height ≈ 54pt vs safeAreaInsets.top ≈ 59pt),
 * and `cordova-plugin-statusbar` itself sizes both its gray status bar backdrop view
 * AND the WebView's top offset using `statusBarFrame.height` (see its `resizeWebView`
 * and `resizeStatusBarBackgroundView` in CDVStatusBar.m). Reading safeAreaInsets.top
 * instead left a gap (the difference between the two values) between the status bar
 * backdrop and the WebView's own top edge, with no background — visible as scrolled
 * content bleeding through. Matching cordova-plugin-statusbar's own reference value
 * keeps everything aligned on the same line, closing that gap.
 *
 * (This is also the same deprecated-but-still-relied-upon API admob-plus itself uses
 * in AMBBanner.swift's `statusBarBackgroundView`, so it's proven to keep compiling.)
 *
 * JS side: cordova.plugins.statusBarInset.getInsetTopPt(successCb, errorCb)
 *   successCb(pt: number)
 *   errorCb(reason: string) — currently never called on iOS (statusBarFrame is always
 *   available), kept for interface symmetry with a possible future failure mode.
 */
@objc(StatusBarInsetPlugin)
class StatusBarInsetPlugin: CDVPlugin {

    @objc(getInsetTopPt:)
    func getInsetTopPt(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            let height = UIApplication.shared.statusBarFrame.height
            let topPt = Int32(height.rounded())
            let result = CDVPluginResult(status: .ok, messageAs: topPt)
            self.commandDelegate.send(result, callbackId: command.callbackId)
        }
    }
}
