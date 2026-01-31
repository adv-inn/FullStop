import Cocoa
import FlutterMacOS
import app_links

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationWillFinishLaunching(_ notification: Notification) {
    // Single-instance guard: if another instance is already running, activate it and quit
    let bundleID = Bundle.main.bundleIdentifier ?? "com.sfo.fullstop"
    let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
    if runningApps.count > 1 {
      for app in runningApps where app != NSRunningApplication.current {
        app.activate()
      }
      print("AppDelegate: Another instance is already running, terminating.")
      NSApp.terminate(nil)
      return
    }

    // Register for URL scheme events before the app finishes launching
    NSAppleEventManager.shared().setEventHandler(
      self,
      andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL)
    )
    super.applicationWillFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    // Return false to allow the app to keep running when minimized to tray
    return false
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    // When the user clicks the Dock icon and the window is hidden (minimized to tray),
    // bring the existing window back to the foreground
    if !flag {
      for window in sender.windows {
        window.makeKeyAndOrderFront(self)
      }
    }
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
    guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else {
      return
    }

    print("AppDelegate: Received URL event: \(urlString)")

    // Forward to app_links plugin
    AppLinks.shared.handleLink(link: urlString)
  }
}
