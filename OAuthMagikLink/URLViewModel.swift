import SwiftUI
import Observation
import os.log

// MARK: - URL ViewModel
//
//  State machine:
//    EMPTY → (user input) → PARSING → VALID | ERROR
//    VALID/ERROR → (edit) → PARSING
//    PANEL CLOSED → (5min timer) → EMPTY
//
//  All business logic lives here. Views are pure rendering.

private let logger = Logger(subsystem: "com.fullya.MagikOAuth", category: "URLViewModel")

@Observable
final class URLViewModel {
    // MARK: - State

    var inputText: String = "" {
        didSet { processInput() }
    }
    var cleanedURL: String = ""
    var errorState: URLError? = nil
    var showParsed: Bool = false
    var copied: Bool = false

    private(set) var params: [OAuthParam] = []
    private(set) var baseEndpoint: String = ""

    var isValid: Bool { !cleanedURL.isEmpty && errorState == nil }
    var hasInput: Bool { !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var wasTruncated: Bool { errorState == .tooLong }

    // MARK: - Dependencies

    private let clipboard: ClipboardManaging
    private var clearTask: Task<Void, Never>?
    private var copiedResetTask: Task<Void, Never>?
    private var clipboardMonitorTask: Task<Void, Never>?
    private var lastChangeCount: Int = 0

    // MARK: - Types

    enum URLError: Equatable {
        case invalidScheme
        case invalidFormat
        case tooLong
        case empty
    }

    struct OAuthParam: Identifiable {
        let id = UUID()
        let key: String
        let value: String
        let color: AuroraColor

        var decodedValue: String {
            value.removingPercentEncoding ?? value
        }
    }

    // MARK: - Init

    init(clipboard: ClipboardManaging = ClipboardManager()) {
        self.clipboard = clipboard
    }

    // MARK: - Input Processing

    private func processInput() {
        copied = false

        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            cleanedURL = ""
            errorState = nil
            params = []
            baseEndpoint = ""
            return
        }

        let result = Self.cleanURL(trimmed)
        cleanedURL = result.url
        errorState = result.error

        if !cleanedURL.isEmpty {
            parseParams()
        } else {
            params = []
            baseEndpoint = ""
        }
    }

    // MARK: - URL Cleaning

    static let maxInputLength = 10_000

    static func cleanURL(_ raw: String) -> (url: String, error: URLError?) {
        var input = raw

        // Truncate if too long
        var wasTruncated = false
        if input.count > maxInputLength {
            input = String(input.prefix(maxInputLength))
            wasTruncated = true
        }

        // Strip whitespace, newlines, carriage returns
        let cleaned = input
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else {
            return ("", .empty)
        }

        // Validate scheme
        guard cleaned.hasPrefix("http://") || cleaned.hasPrefix("https://") else {
            return ("", .invalidScheme)
        }

        // Validate URL structure
        guard URL(string: cleaned) != nil else {
            return ("", .invalidFormat)
        }

        return (cleaned, wasTruncated ? .tooLong : nil)
    }

    // MARK: - URL Parsing

    private func parseParams() {
        guard let components = URLComponents(string: cleanedURL) else {
            params = []
            baseEndpoint = ""
            return
        }

        baseEndpoint = "\(components.scheme ?? "https")://\(components.host ?? "")\(components.path)"

        params = (components.queryItems ?? []).map { item in
            OAuthParam(
                key: item.name,
                value: item.value ?? "",
                color: OAuthParamClassifier.classify(item.name)
            )
        }
    }

    // MARK: - Actions

    func pasteFromClipboard() {
        guard let clip = clipboard.readString(),
              clip.contains("http://") || clip.contains("https://") else {
            return
        }
        inputText = clip
    }

    func copyToClipboard() {
        guard isValid else { return }
        clipboard.writeString(cleanedURL)

        withAnimation(AppTheme.Animation.fast) { copied = true }

        copiedResetTask?.cancel()
        copiedResetTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            withAnimation(AppTheme.Animation.fast) { copied = false }
        }
    }

    func openInBrowser() {
        guard isValid, let url = URL(string: cleanedURL) else { return }
        NSWorkspace.shared.open(url)
    }

    func reset() {
        inputText = ""
        cleanedURL = ""
        errorState = nil
        params = []
        baseEndpoint = ""
        copied = false
        showParsed = false
    }

    // MARK: - Panel Lifecycle

    func onPanelOpen() {
        cancelClearTimer()
        startClipboardMonitor()
    }

    func onPanelClose() {
        stopClipboardMonitor()
        startClearTimer()
    }

    // MARK: - Clipboard Monitor
    //
    //  Polls NSPasteboard.changeCount every 0.5s while the panel is open.
    //  When a new URL is detected in the clipboard, auto-pastes it.
    //  Cost: ~1µs per check (integer comparison). Stops when panel closes.

    private func startClipboardMonitor() {
        lastChangeCount = clipboard.changeCount
        clipboardMonitorTask?.cancel()
        clipboardMonitorTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }

                let currentCount = clipboard.changeCount
                guard currentCount != lastChangeCount else { continue }
                lastChangeCount = currentCount

                // New clipboard content — check if it's a URL
                guard let clip = clipboard.readString(),
                      clip.contains("http://") || clip.contains("https://") else {
                    continue
                }

                // Don't re-paste the same URL we just copied
                guard clip != cleanedURL else { continue }

                inputText = clip
                logger.debug("Auto-pasted URL from clipboard")
            }
        }
    }

    private func stopClipboardMonitor() {
        clipboardMonitorTask?.cancel()
        clipboardMonitorTask = nil
    }

    private func startClearTimer() {
        clearTask?.cancel()
        clearTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(300))
            guard !Task.isCancelled else { return }
            reset()
            logger.debug("State cleared after 5min timeout")
        }
    }

    private func cancelClearTimer() {
        clearTask?.cancel()
        clearTask = nil
    }

    // MARK: - Error Messages

    var errorMessage: String? {
        guard let error = errorState else { return nil }
        switch error {
        case .invalidScheme:
            return "URL must start with http:// or https://"
        case .invalidFormat:
            return "Invalid URL format"
        case .tooLong:
            return "URL truncated to \(Self.maxInputLength) characters"
        case .empty:
            return nil
        }
    }
}
