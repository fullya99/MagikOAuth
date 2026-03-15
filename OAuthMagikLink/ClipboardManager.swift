import AppKit

// MARK: - Clipboard Manager
//
//  Thin wrapper around NSPasteboard for testability.
//  Protocol-based so unit tests can inject a mock.
//
//  Also provides clipboard monitoring via changeCount polling.
//  Monitoring only runs while the panel is open (started/stopped explicitly).
//  Polls every 0.5s — cost: ~1µs per check (integer comparison).

protocol ClipboardReading {
    func readString() -> String?
    var changeCount: Int { get }
}

protocol ClipboardWriting {
    func writeString(_ value: String)
}

typealias ClipboardManaging = ClipboardReading & ClipboardWriting

struct ClipboardManager: ClipboardManaging {
    static let maxReadLength = 10_000

    var changeCount: Int {
        NSPasteboard.general.changeCount
    }

    func readString() -> String? {
        guard let raw = NSPasteboard.general.string(forType: .string) else {
            return nil
        }
        if raw.count > Self.maxReadLength {
            return String(raw.prefix(Self.maxReadLength))
        }
        return raw
    }

    func writeString(_ value: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
    }
}
