import AppKit
import Carbon.HIToolbox
import os.log

// MARK: - Global Shortcut Manager
//
//  Registers a global keyboard shortcut (default: Cmd+Shift+C)
//  to toggle the floating panel from anywhere.
//
//  Requires Accessibility permission (System Settings > Privacy > Accessibility).
//  Shows an alert with a link to System Settings if permission is denied.

private let logger = Logger(subsystem: "com.fullya.MagikOAuth", category: "GlobalShortcut")

final class GlobalShortcut {
    private var monitor: Any?
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    func register() {
        // Check accessibility permission
        let trusted = AXIsProcessTrusted()
        if !trusted {
            requestAccessibilityPermission()
        }

        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }

        logger.info("Global shortcut registered (Cmd+Shift+C)")
    }

    func unregister() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
        logger.info("Global shortcut unregistered")
    }

    private func handleKeyEvent(_ event: NSEvent) {
        // Filter: Cmd + Shift + C
        let requiredFlags: NSEvent.ModifierFlags = [.command, .shift]
        let pressedFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        guard pressedFlags == requiredFlags,
              event.keyCode == UInt16(kVK_ANSI_C) else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.action()
        }
    }

    private func requestAccessibilityPermission() {
        logger.warning("Accessibility permission not granted")

        let alert = NSAlert()
        alert.messageText = "MagikOAuth needs Accessibility access"
        alert.informativeText = "To use the global shortcut Cmd+Shift+C, grant MagikOAuth access in System Settings > Privacy > Accessibility."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Later")

        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    deinit {
        unregister()
    }
}
