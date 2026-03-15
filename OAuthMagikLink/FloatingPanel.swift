import AppKit
import SwiftUI

// MARK: - Floating Panel
//
//  Custom NSPanel subclass for the MagikOAuth popup.
//
//  Behavior:
//    - No title bar, no toolbar
//    - Non-activating (doesn't steal focus from other apps)
//    - Closes on resign key (click outside)
//    - Corner radius 14px, deep shadow
//    - Positioned below the menu bar status item
//
//  Lifecycle:
//    FloatingPanelController creates and owns this panel.
//    The panel hosts a SwiftUI ContentView via NSHostingView.

class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )

        isFloatingPanel = true
        level = .statusBar
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = false
        isReleasedWhenClosed = false
        hidesOnDeactivate = false

        // Animate appearance
        animationBehavior = .utilityWindow
    }

    override func resignKey() {
        super.resignKey()
        close()
    }
}

// MARK: - Floating Panel Controller

final class FloatingPanelController {
    let viewModel: URLViewModel
    private var panel: FloatingPanel?
    private var shortcut: GlobalShortcut?
    private var hostingView: NSHostingView<ContentView>?
    private var resizeTask: Task<Void, Never>?

    init() {
        self.viewModel = URLViewModel()
    }

    func setupPanel() {
        let contentRect = NSRect(x: 0, y: 0, width: AppTheme.Panel.width, height: AppTheme.Panel.minHeight)
        let panel = FloatingPanel(contentRect: contentRect)

        let contentView = ContentView(viewModel: viewModel)

        let hosting = NSHostingView(rootView: contentView)
        hosting.layer?.cornerRadius = AppTheme.Panel.cornerRadius
        hosting.layer?.masksToBounds = true
        // Let the hosting view size itself to fit content
        hosting.sizingOptions = [.intrinsicContentSize]

        panel.contentView = hosting
        self.panel = panel
        self.hostingView = hosting
    }

    func setupShortcut() {
        shortcut = GlobalShortcut { [weak self] in
            self?.togglePanel()
        }
        shortcut?.register()
    }

    var isPanelVisible: Bool {
        panel?.isVisible ?? false
    }

    func togglePanel() {
        guard let panel else { return }

        if panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    func showPanel(relativeTo statusItemButton: NSStatusBarButton? = nil) {
        guard let panel, let hostingView else { return }

        viewModel.onPanelOpen()

        // Auto-paste if clipboard has a URL
        if !viewModel.hasInput {
            viewModel.pasteFromClipboard()
        }

        // Let the hosting view compute its ideal size
        let idealSize = hostingView.intrinsicContentSize
        let height = min(max(idealSize.height, AppTheme.Panel.minHeight), AppTheme.Panel.maxHeight)
        panel.setContentSize(NSSize(width: AppTheme.Panel.width, height: height))

        positionPanel(relativeTo: statusItemButton)

        panel.makeKeyAndOrderFront(nil)

        // Animate in: fade
        panel.alphaValue = 0
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }
    }

    func hidePanel() {
        guard let panel, panel.isVisible else { return }

        viewModel.onPanelClose()

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak panel] in
            panel?.orderOut(nil)
        })
    }

    // MARK: - Panel Positioning

    private func positionPanel(relativeTo button: NSStatusBarButton?) {
        guard let panel, let screen = NSScreen.main else { return }

        let panelSize = panel.frame.size
        let screenFrame = screen.visibleFrame

        // Try to center below the status item button
        var origin: NSPoint

        if let button, let buttonWindow = button.window {
            let buttonFrame = buttonWindow.frame
            let centerX = buttonFrame.midX - panelSize.width / 2

            // Anchor below the menu bar
            let topY = screenFrame.maxY - panelSize.height

            origin = NSPoint(
                x: centerX.clamped(to: screenFrame.minX...screenFrame.maxX - panelSize.width),
                y: topY
            )
        } else {
            // Fallback: center of screen, near top
            origin = NSPoint(
                x: screenFrame.midX - panelSize.width / 2,
                y: screenFrame.maxY - panelSize.height - 8
            )
        }

        panel.setFrameOrigin(origin)
    }

    /// Update panel height based on content, with debounce.
    func updatePanelHeight(_ newHeight: CGFloat) {
        guard let panel else { return }

        let clampedHeight = min(max(newHeight, AppTheme.Panel.minHeight), AppTheme.Panel.maxHeight)
        let currentFrame = panel.frame

        // Grow downward from current top edge
        let newOrigin = NSPoint(x: currentFrame.origin.x, y: currentFrame.maxY - clampedHeight)
        let newFrame = NSRect(origin: newOrigin, size: NSSize(width: AppTheme.Panel.width, height: clampedHeight))

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.3
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().setFrame(newFrame, display: true)
        }
    }

    deinit {
        shortcut?.unregister()
    }
}

// MARK: - Comparable Clamped Extension

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
