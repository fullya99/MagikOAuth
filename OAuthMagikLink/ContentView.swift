import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var cleanedURL: String = ""
    @State private var copied = false
    @State private var hoveredParam: String?
    @State private var showParsed = false

    private var parsedParams: [(key: String, value: String)] {
        guard let comps = URLComponents(string: cleanedURL) else { return [] }
        return (comps.queryItems ?? []).map { ($0.name, $0.value ?? "") }
    }

    private var baseURL: String {
        guard let comps = URLComponents(string: cleanedURL) else { return "" }
        return "\(comps.scheme ?? "https")://\(comps.host ?? "")\(comps.path)"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            Divider().opacity(0.5)

            // Content
            ScrollView {
                VStack(spacing: 16) {
                    inputSection
                    if !cleanedURL.isEmpty {
                        outputSection
                        actionButtons
                    }
                }
                .padding(16)
            }
        }
        .frame(width: 440, height: 420)
        .background(.ultraThinMaterial)
        .onAppear { pasteFromClipboard() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.linearGradient(
                    colors: [.purple, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            Text("MagikLink")
                .font(.system(size: 14, weight: .semibold, design: .rounded))

            Spacer()

            Button {
                inputText = ""
                cleanedURL = ""
                copied = false
                showParsed = false
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Reset")

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .buttonStyle(.plain)
            .help("Quitter")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Input

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Coller le lien brut", systemImage: "doc.on.clipboard")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)

            ZStack(alignment: .topLeading) {
                if inputText.isEmpty {
                    Text("https://claude.ai/oauth/authorize?code=...")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $inputText)
                    .font(.system(size: 11, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(4)
                    .onChange(of: inputText) { _, newValue in
                        cleanedURL = cleanURL(newValue)
                        copied = false
                    }
            }
            .frame(height: 72)
            .background(Color(.textBackgroundColor).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
    }

    // MARK: - Output

    private var outputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Lien reconstruit", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.green)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showParsed.toggle()
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: showParsed ? "list.bullet" : "eye")
                            .font(.system(size: 9))
                        Text(showParsed ? "Params" : "Inspecter")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            if showParsed {
                parsedParamsView
            } else {
                Text(cleanedURL)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.85))
                    .lineLimit(4)
                    .truncationMode(.middle)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.green.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.green.opacity(0.15), lineWidth: 1)
                    )
            }
        }
    }

    private var parsedParamsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Base URL
            HStack(spacing: 6) {
                Text("endpoint")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(.purple)
                    .frame(width: 90, alignment: .trailing)
                Text(baseURL)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.7))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 8)

            ForEach(Array(parsedParams.enumerated()), id: \.offset) { idx, param in
                Divider().opacity(0.3)
                HStack(spacing: 6) {
                    Text(param.key)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundColor(.blue)
                        .frame(width: 90, alignment: .trailing)
                        .lineLimit(1)
                    Text(param.value.removingPercentEncoding ?? param.value)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.7))
                        .lineLimit(2)
                        .textSelection(.enabled)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(idx % 2 == 0 ? Color.primary.opacity(0.02) : .clear)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Actions

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button(action: copyToClipboard) {
                HStack(spacing: 6) {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 11, weight: .medium))
                    Text(copied ? "Copie !" : "Copier")
                        .font(.system(size: 12, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(copied
                              ? Color.green.opacity(0.15)
                              : Color.accentColor.opacity(0.12))
                )
                .foregroundColor(copied ? .green : .accentColor)
            }
            .buttonStyle(.plain)

            Button(action: openInBrowser) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .medium))
                    Text("Ouvrir")
                        .font(.system(size: 12, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primary.opacity(0.06))
                )
                .foregroundColor(.primary.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Logic

    private func cleanURL(_ raw: String) -> String {
        let cleaned = raw
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard cleaned.hasPrefix("http://") || cleaned.hasPrefix("https://") else {
            return ""
        }
        return cleaned
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(cleanedURL, forType: .string)
        withAnimation(.easeInOut(duration: 0.15)) { copied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { copied = false }
        }
    }

    private func openInBrowser() {
        if let url = URL(string: cleanedURL) {
            NSWorkspace.shared.open(url)
        }
    }

    private func pasteFromClipboard() {
        if let clip = NSPasteboard.general.string(forType: .string),
           clip.contains("http") {
            inputText = clip
        }
    }
}

#Preview {
    ContentView()
}
