import SwiftUI
import AppKit
import SystemConfiguration

struct NightShiftAgentApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() } // No window needed
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var isEnabled = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "NightShift"
        statusItem?.menu = buildMenu()

        // Listen for sleep notifications to re-register.
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(willSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        let toggle = NSMenuItem(title: isEnabled ? "Disable" : "Enable", action: #selector(toggleProxy), keyEquivalent: "")
        toggle.target = self
        menu.addItem(toggle)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }

    @objc private func toggleProxy() {
        isEnabled.toggle()
        statusItem?.button?.title = isEnabled ? "NightShift ✅" : "NightShift"
        statusItem?.menu = buildMenu() // Refresh menu title

        if isEnabled {
            registerWithProxy()
        }
    }

    @objc private func willSleep() {
        guard isEnabled else { return }
        registerWithProxy() // Re-register on sleep
    }

    private func registerWithProxy() {
        // NOTE: Replace the MAC/IP arguments below with your machine's values.
        let task = Process()
        task.launchPath = "/usr/bin/dns-sd"
        task.arguments = [
            "-R",
            "MyMac",
            "_sleep-proxy._udp",
            "local",
            "9",
            "mac=aa:bb:cc:dd:ee:ff",
            "ip=192.168.1.100"
        ]

        task.launch()
        task.waitUntilExit()

        if task.terminationStatus == 0 {
            NSLog("Registered with proxy")
        } else {
            NSLog("dns-sd failed with status %d", task.terminationStatus)
        }
    }
}
