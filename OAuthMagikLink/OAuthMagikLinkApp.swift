import SwiftUI

// MARK: - MagikOAuth App
//
//  Architecture: MenuBarExtra (SwiftUI native) + FloatingPanel (NSPanel custom)
//
//  The MenuBarExtra provides the status item in the menu bar.
//  Clicking it toggles the FloatingPanel which hosts the ContentView.
//  A global shortcut (Cmd+Shift+C) also toggles the panel.
//
//  Dependencies:
//    FloatingPanelController → owns URLViewModel + FloatingPanel + GlobalShortcut

@main
struct MagikOAuthApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {}
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var panelController: FloatingPanelController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from dock
        NSApp.setActivationPolicy(.accessory)

        // Setup panel controller
        panelController = FloatingPanelController()
        panelController.setupPanel()
        panelController.setupShortcut()

        // Setup status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // Use diamond SF Symbol matching our brand
            let image = NSImage(systemSymbolName: "diamond.fill", accessibilityDescription: "MagikOAuth")
            image?.isTemplate = true // Adapts to menu bar appearance (light/dark)
            button.image = image
            button.action = #selector(statusItemClicked)
            button.target = self
        }
    }

    @objc func statusItemClicked() {
        if panelController.isPanelVisible {
            panelController.hidePanel()
        } else if let button = statusItem.button {
            panelController.showPanel(relativeTo: button)
        }
    }
}
